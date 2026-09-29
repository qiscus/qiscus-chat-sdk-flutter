// Headless end-to-end check for qiscus_chat_sdk. No Flutter UI: it drives the
// real SDK against a real Qiscus app from the plain Dart VM.
//
//   dart run tool/e2e.dart [sync|realtime|all]
//
// Two SDK sessions log in as different users. The "sender" posts a burst of
// messages into a fresh group chat; the "listener" collects what
// `onMessageReceived()` delivers and the raw `/sync` responses it got.
//
//   sync      listener has realtime turned off, so every message must come
//             through the REST sync path (the path with the ordering bug).
//   realtime  listener has realtime on, so messages can arrive twice, once
//             pushed and once from the sync safety net.
//
// The sender and the listener must be different users: the server does not
// echo a user's own messages back to them, neither over realtime nor /sync.
//
// Credentials default to the `sdksample` app; override with E2E_APP_ID,
// E2E_USER_ID / E2E_USER_KEY (listener) and E2E_SENDER_ID / E2E_SENDER_KEY.
// Every scenario creates one new group chat named `e2e-sdk-order-<millis>` in
// that app; there is no delete API, so it stays.
//
// It has to be a group chat: on `sdksample`, `/sync` returns nothing for
// channels and 1:1 rooms (checked 2026-09-29), so the sync path cannot be
// exercised there.

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

String _env(String key, String fallback) =>
    Platform.environment[key] ?? fallback;

final appId = _env('E2E_APP_ID', 'sdksample');
final userId = _env('E2E_USER_ID', 'guest-1001');
final userKey = _env('E2E_USER_KEY', 'passkey');
final senderId = _env('E2E_SENDER_ID', 'guest-1002');
final senderKey = _env('E2E_SENDER_KEY', 'passkey');

const messageCount = 12;
const syncIntervalMs = 3000;

/// The sample app rate-limits bursts (HTTP 429). About 0.8s per message is what
/// the production repro used and stays under the limit.
const sendGapMs = 800;

/// Deliveries closer together than this belong to one sync batch.
const burstGapMs = 700;

class Delivery {
  Delivery(this.message, this.atMs);
  final QMessage message;
  final int atMs;
}

class Session {
  Session(this.sdk, this.rawSyncs);
  final QiscusSDK sdk;

  /// Comment ids of every non-empty `/sync` response, in server order.
  final List<List<int>> rawSyncs;
}

class Check {
  Check(this.name, this.ok, this.detail);
  final String name;
  final bool ok;
  final String detail;
}

Future<QMessage> sendWithRetry(QiscusSDK sdk, QMessage message) async {
  for (var attempt = 1;; attempt++) {
    try {
      return await sdk.sendMessage(message: message);
    } catch (error) {
      if (attempt >= 5 || !error.toString().contains('429')) rethrow;
      await Future<void>.delayed(Duration(seconds: 2 * attempt));
    }
  }
}

Future<Session> login({
  required String id,
  required String key,
  required bool realtime,
}) async {
  var sdk = QiscusSDK();
  var rawSyncs = <List<int>>[];

  sdk.dio.interceptors.add(InterceptorsWrapper(onResponse: (res, handler) {
    if (res.requestOptions.uri.path.endsWith('/sync')) {
      try {
        var comments = (res.data['results']['comments'] as List).cast<Map>();
        if (comments.isNotEmpty) {
          rawSyncs.add([for (var c in comments) c['id'] as int]);
        }
      } catch (_) {}
    }
    handler.next(res);
  }));

  // `setup` overwrites these from the server config, so set them afterwards.
  await sdk.setup(appId);
  sdk.storage.isRealtimeEnabled = realtime;
  sdk.setSyncInterval(syncIntervalMs.toDouble());
  sdk.setSyncIntervalWhenConnected(syncIntervalMs.toDouble());

  await sdk.setUser(userId: id, userKey: key);
  return Session(sdk, rawSyncs);
}

Future<List<Check>> runScenario(String name, {required bool realtime}) async {
  var checks = <Check>[];
  void check(String name, bool ok, String detail) =>
      checks.add(Check(name, ok, detail));

  var listener = await login(id: userId, key: userKey, realtime: realtime);
  var sender = await login(id: senderId, key: senderKey, realtime: false);

  if (realtime) {
    // Realtime needs a moment to finish connecting after login.
    var deadline = DateTime.now().add(const Duration(seconds: 10));
    while (DateTime.now().isBefore(deadline) &&
        !listener.sdk.mqtt.connectionStatus!.state.toString().contains(
              'connected',
            )) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    var state = listener.sdk.mqtt.connectionStatus?.state;
    check('realtime connection is up', state.toString() == 'MqttConnectionState.connected',
        'state=$state');
  }

  var roomName = 'e2e-sdk-order-${DateTime.now().millisecondsSinceEpoch}';
  var room = await listener.sdk.createGroupChat(
    name: roomName,
    userIds: [senderId],
  );

  var clock = Stopwatch()..start();
  var deliveries = <Delivery>[];
  var subscription = listener.sdk.onMessageReceived().listen((m) {
    // The sample app is shared; ignore traffic from any other room.
    if (m.chatRoomId == room.id) {
      deliveries.add(Delivery(m, clock.elapsedMilliseconds));
    }
  });
  await Future<void>.delayed(const Duration(milliseconds: 500));

  var sent = <QMessage>[];
  for (var i = 1; i <= messageCount; i++) {
    var text = 'e2e-${i.toString().padLeft(2, '0')}';
    var message = sender.sdk.generateMessage(chatRoomId: room.id, text: text);
    sent.add(await sendWithRetry(sender.sdk, message));
    await Future<void>.delayed(const Duration(milliseconds: sendGapMs));
  }
  var sentIds = sent.map((m) => m.id).toList();
  print('  room ${room.id} ($roomName), sent ids $sentIds');

  // Wait for everything to arrive, then keep listening for two more sync
  // cycles: a broken cursor shows up as messages delivered again.
  var deadline = DateTime.now().add(const Duration(seconds: 45));
  while (DateTime.now().isBefore(deadline) &&
      !sentIds.every((id) => deliveries.any((d) => d.message.id == id))) {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
  await Future<void>.delayed(
    const Duration(milliseconds: syncIntervalMs * 2 + 1500),
  );
  await subscription.cancel();

  var deliveredIds = deliveries.map((d) => d.message.id).toList();
  print('  delivered ids $deliveredIds');

  var missing = sentIds.where((id) => !deliveredIds.contains(id)).toList();
  check('every sent message is delivered', missing.isEmpty,
      missing.isEmpty ? '${sentIds.length}/${sentIds.length}' : 'missing $missing');

  var counts = <int, int>{};
  for (var id in deliveredIds) {
    counts[id] = (counts[id] ?? 0) + 1;
  }
  var duplicates = {
    for (var e in counts.entries)
      if (e.value > 1) e.key: e.value
  };
  check('each message is delivered exactly once', duplicates.isEmpty,
      duplicates.isEmpty ? 'no duplicates' : 'delivered more than once $duplicates');

  var bursts = <List<Delivery>>[];
  for (var d in deliveries) {
    if (bursts.isEmpty || d.atMs - bursts.last.last.atMs > burstGapMs) {
      bursts.add([]);
    }
    bursts.last.add(d);
  }
  var inversions = 0;
  for (var burst in bursts) {
    for (var i = 1; i < burst.length; i++) {
      if (burst[i].message.timestamp.isBefore(burst[i - 1].message.timestamp)) {
        inversions++;
      }
    }
  }
  if (!realtime) {
    check('each sync batch is delivered oldest first by timestamp',
        inversions == 0,
        '$inversions inversions across ${bursts.length} batches '
        '(sizes ${bursts.map((b) => b.length).toList()})');
  } else {
    print('  info: ${bursts.length} delivery bursts, $inversions inversions '
        '(order across realtime and sync is not guaranteed)');
  }

  var ours = sentIds.toSet();
  var occurrences = 0;
  for (var response in listener.rawSyncs) {
    occurrences += response.where(ours.contains).length;
  }
  var refetched = occurrences - ours.where((id) {
    return listener.rawSyncs.any((r) => r.contains(id));
  }).length;
  check('sync does not refetch messages already received', refetched == 0,
      'server returned our messages $occurrences times for '
      '${ours.length} messages; $refetched refetched');

  var firstWithOurs = listener.rawSyncs.firstWhere(
    (r) => r.any(ours.contains),
    orElse: () => <int>[],
  );
  if (firstWithOurs.isNotEmpty) {
    var mine = firstWithOurs.where(ours.contains).toList();
    var sorted = [...mine]..sort();
    print('  info: first /sync batch with our messages came back as '
        '${mine == sorted ? 'ascending' : mine.reversed.toList().toString() == sorted.toString() ? 'descending' : 'unordered'}: $mine');
  }

  var cursor = listener.sdk.storage.lastMessageId;
  var newest = sentIds.reduce((a, b) => a > b ? a : b);
  check('cursor ends at the newest id', cursor >= newest,
      'lastMessageId=$cursor, newest sent=$newest');

  await listener.sdk.clearUser();
  await sender.sdk.clearUser();
  return checks;
}

Future<void> main(List<String> args) async {
  var which = args.isEmpty ? 'all' : args.first;
  var scenarios = <String, bool>{
    if (which == 'sync' || which == 'all') 'sync': false,
    if (which == 'realtime' || which == 'all') 'realtime': true,
  };
  if (scenarios.isEmpty) {
    stderr.writeln('usage: dart run tool/e2e.dart [sync|realtime|all]');
    exit(64);
  }

  print('qiscus_chat_sdk e2e: app=$appId listener=$userId sender=$senderId');
  var failed = 0;
  for (var entry in scenarios.entries) {
    print('\n[${entry.key}]');
    try {
      var checks = await runScenario(entry.key, realtime: entry.value)
          .timeout(const Duration(minutes: 3));
      for (var c in checks) {
        if (!c.ok) failed++;
        print('  ${c.ok ? 'PASS' : 'FAIL'}  ${c.name} - ${c.detail}');
      }
    } catch (error, stack) {
      failed++;
      print('  FAIL  scenario crashed - $error\n$stack');
    }
  }

  print(failed == 0 ? '\nALL PASSED' : '\n$failed CHECK(S) FAILED');
  exit(failed == 0 ? 0 : 1);
}
