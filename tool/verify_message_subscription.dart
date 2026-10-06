// Headless live reproduction; deliberately does NOT patch the SDK.
// dart run tool/verify_message_subscription.dart [before|after|all]
//   [--no-sync] [--summary=/absolute/path.json]
// E2E_APP_ID, E2E_USER_ID/KEY, E2E_SENDER_ID/KEY match tool/e2e.dart.
// Each scenario leaves a new synthetic group room (there is no delete API).
// JSON events use one local Stopwatch; no tokens, topics or server clock.
// Read-only dependency diagnostics, intentionally inspecting callback snapshots.
// ignore_for_file: invalid_use_of_protected_member
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

String env(String name, String fallback) =>
    Platform.environment[name] ?? fallback;
final app = env('E2E_APP_ID', 'sdksample');
final listenerId = env('E2E_USER_ID', 'guest-1001');
final senderId = env('E2E_SENDER_ID', 'guest-1002');
const syncMs = 30000;
const realtimeBudgetMs = 1000;
const httpTimeout = Duration(seconds: 20);

// Error strings can contain credentials/request bodies: report type/status only.
Map<String, Object?> safeError(Object error) => {
      'kind': error.runtimeType.toString(),
      if (error is DioException) 'httpStatus': error.response?.statusCode,
      if (error.toString().contains('429')) 'rateLimited': true,
    };

Future<QMessage> sendWithRetry(QiscusSDK sdk, QMessage message) async {
  for (var attempt = 1;; attempt++) {
    try {
      return await sdk.sendMessage(message: message).timeout(httpTimeout);
    } catch (error) {
      if (attempt >= 4 || !error.toString().contains('429')) rethrow;
      print(jsonEncode({'event': 'retry429', 'attempt': attempt}));
      await Future<void>.delayed(Duration(seconds: 2 * attempt));
    }
  }
}

class Reproduction {
  Reproduction(this.name, this.noSync);
  final String name;
  final bool noSync;
  final listener = QiscusSDK(), sender = QiscusSDK();
  final clock = Stopwatch()..start();
  final sent = <Map<String, Object?>>[], raw = <Map<String, Object?>>[];
  final sdkEvents = <Map<String, Object?>>[], syncs = <Map<String, Object?>>[];
  final states = <Map<String, Object?>>[], errors = <Map<String, Object?>>[];
  final subscriptions = <StreamSubscription<dynamic>>[];
  Object? rawManager;
  Timer? monitor;
  int? roomId;
  bool stopped = false;
  String? lastState;

  void event(String type, Map<String, Object?> data) => print(jsonEncode({
        'scenario': name,
        'event': type,
        'atMs': clock.elapsedMilliseconds,
        ...data,
      }));

  void error(String source, Object error) {
    final data = {
      'source': source,
      'atMs': clock.elapsedMilliseconds,
      ...safeError(error)
    };
    errors.add(data);
    event('error', data);
  }

  void attachSdk() {
    // FIRST access to any lazy realtime stream. BEFORE calls this before setUser;
    // AFTER calls it only after both MQTT connected and message SUBACK active.
    subscriptions.add(listener.onMessageReceived().listen((m) {
      if (m.chatRoomId != roomId) return;
      final data = <String, Object?>{
        'id': m.id,
        'atMs': clock.elapsedMilliseconds
      };
      sdkEvents.add(data);
      event('sdk', data);
    }, onError: (Object e) => error('sdkStream', e)));
    final mqtt = listener.mqtt;
    event('attachSdk', {
      'loggedIn': listener.isLogin,
      'state': mqtt.connectionStatus?.state.name,
      'clientConnectedCallback': mqtt.onConnected != null,
      'handlerConnectedCallback': mqtt.connectionHandler?.onConnected != null,
      'connectedCallbacksIdentical':
          identical(mqtt.onConnected, mqtt.connectionHandler?.onConnected),
      'handlerReconnectCallback':
          mqtt.connectionHandler?.onAutoReconnected != null,
    });
  }

  // Observe only: never assign onConnected/onAutoReconnected or subscribe topics.
  void observeMqtt() {
    final mqtt = listener.mqtt;
    final status = mqtt.connectionStatus;
    final state = {
      'state': status?.state.name,
      'returnCode': status?.returnCode?.name,
      'origin': status?.disconnectionOrigin.name,
      'reconnecting': mqtt.connectionHandler?.autoReconnectInProgress ?? false,
    };
    if (jsonEncode(state) != lastState) {
      lastState = jsonEncode(state);
      states.add({'atMs': clock.elapsedMilliseconds, ...state});
      event('mqttState', state);
    }
    // updates/StreamController.stream can return a fresh wrapper each read.
    // Track the manager identity, not the wrapper, to avoid observer duplicates.
    final manager = mqtt.subscriptionsManager;
    if (manager == null || identical(manager, rawManager)) return;
    final updates = mqtt.updates;
    if (updates == null) return;
    rawManager = manager;
    subscriptions.add(updates.listen((batch) {
      for (final update in batch) {
        if (!update.topic.endsWith('/c')) continue;
        try {
          final payload = update.payload as MqttPublishMessage;
          final data = jsonDecode(utf8.decode(payload.payload.message)) as Map;
          if (data['room_id'] != roomId) continue;
          final row = <String, Object?>{
            'id': data['id'],
            'text': data['message'],
            'roomId': data['room_id'],
            'atMs': clock.elapsedMilliseconds,
          };
          raw.add(row);
          event('rawMqtt', row);
        } catch (e) {
          error('rawDecode', e);
        }
      }
    },
        onError: (Object e) => error('rawStream', e),
        onDone: () => event('rawDone', {})));
    event('attachRaw', {});
  }

  Future<void> setup(QiscusSDK sdk, bool realtime) async {
    sdk.enableDebugMode(enable: false);
    sdk.dio.options.connectTimeout = httpTimeout;
    sdk.dio.options.receiveTimeout = httpTimeout;
    sdk.dio.options.sendTimeout = httpTimeout;
    await sdk.setup(app).timeout(httpTimeout);
    // setup overwrites server configuration, hence all overrides go afterwards.
    sdk.storage.isRealtimeEnabled = realtime;
    sdk.storage.isSyncEnabled = !noSync;
    sdk.setSyncInterval(syncMs.toDouble());
    sdk.setSyncIntervalWhenConnected(syncMs.toDouble());
  }

  Future<void> waitReady() async {
    final deadline = clock.elapsedMilliseconds + 25000;
    while (!stopped && clock.elapsedMilliseconds < deadline) {
      observeMqtt();
      final mqtt = listener.mqtt;
      if (mqtt.connectionStatus?.state == MqttConnectionState.connected &&
          listener.token != null &&
          mqtt.updates != null &&
          mqtt.getSubscriptionsStatus('${listener.token}/c') ==
              MqttSubscriptionStatus.active) {
        event('ready', {'state': 'connected', 'messageSubscription': 'active'});
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    throw TimeoutException('MQTT connected + message SUBACK not ready');
  }

  Future<void> exercise() async {
    await setup(listener, true);
    listener.dio.interceptors
        .add(InterceptorsWrapper(onResponse: (res, handler) {
      if (res.requestOptions.uri.path.endsWith('/sync')) {
        try {
          final comments =
              (res.data['results']['comments'] as List).cast<Map>();
          final ids = [for (final c in comments) c['id']];
          final ours = [
            for (final c in comments)
              if (c['room_id'] == roomId) c['id']
          ];
          final row = <String, Object?>{
            'atMs': clock.elapsedMilliseconds,
            'ids': ids,
            'roomIds': ours
          };
          syncs.add(row);
          event('restSync', {'count': ids.length, 'roomIds': ours});
        } catch (e) {
          error('syncDecode', e);
        }
      }
      handler.next(res);
    }));
    if (name == 'before') attachSdk();
    subscriptions
        .add(listener.onRealtimeError().listen((e) => error('realtime', e)));
    event('loginStart', {});
    await listener
        .setUser(userId: listenerId, userKey: env('E2E_USER_KEY', 'passkey'))
        .timeout(httpTimeout);
    event('loginAck', {'state': listener.mqtt.connectionStatus?.state.name});
    monitor =
        Timer.periodic(const Duration(milliseconds: 50), (_) => observeMqtt());
    await waitReady();
    if (name == 'after') attachSdk();
    await setup(sender, false);
    await sender
        .setUser(userId: senderId, userKey: env('E2E_SENDER_KEY', 'passkey'))
        .timeout(httpTimeout);
    final roomName =
        'e2e-sdk-sub-$name-${DateTime.now().microsecondsSinceEpoch}';
    final room = await listener.createGroupChat(
        name: roomName, userIds: [senderId]).timeout(httpTimeout);
    roomId = room.id;
    event('room', {
      'roomId': roomId,
      'name': roomName,
      'syncEnabled': !noSync,
      'syncIntervalMs': syncMs
    });
    for (var i = 1; i <= 3 && !stopped; i++) {
      final text = '$roomName-$i';
      final start = clock.elapsedMilliseconds;
      event('sendStart', {'text': text, 'roomId': roomId});
      final m = await sendWithRetry(
          sender, sender.generateMessage(chatRoomId: room.id, text: text));
      final row = <String, Object?>{
        'id': m.id,
        'text': text,
        'roomId': room.id,
        'sendStartMs': start,
        'sendAckMs': clock.elapsedMilliseconds
      };
      sent.add(row);
      event('sendAck', row);
      await Future<void>.delayed(const Duration(milliseconds: 800));
    }
    // Fixed bounded observation window captures the normal 30s REST safety net,
    // delayed broker arrivals, missing SDK events, and duplicate deliveries.
    final deadline = clock.elapsedMilliseconds + 45000;
    while (!stopped && clock.elapsedMilliseconds < deadline) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<Map<String, Object?>> run() async {
    try {
      await exercise().timeout(const Duration(seconds: 110));
    } catch (e) {
      error('scenario', e);
    } finally {
      stopped = true;
      monitor?.cancel();
      // Cancel application/raw/error listeners and both SDK connections even on
      // login/connect/send failure. Bound cleanup; main also has a hard watchdog.
      for (final sub in subscriptions) {
        try {
          await sub.cancel().timeout(const Duration(seconds: 2));
        } catch (e) {
          error('cancel', e);
        }
      }
      for (final sdk in [listener, sender]) {
        try {
          sdk.mqtt.autoReconnect = false;
          await sdk.clearUser().timeout(const Duration(seconds: 2));
          sdk.dio.close(force: true);
          event('cleanup', {
            'session': identical(sdk, listener) ? 'listener' : 'sender',
            'loggedIn': sdk.isLogin,
            'state': sdk.mqtt.connectionStatus?.state.name,
          });
        } catch (e) {
          error('cleanup', e);
        }
      }
    }
    final rows = <Map<String, Object?>>[];
    for (final message in sent) {
      final id = message['id'];
      final r =
          raw.where((e) => e['id'] == id).map((e) => e['atMs'] as int).toList();
      final s = sdkEvents
          .where((e) => e['id'] == id)
          .map((e) => e['atMs'] as int)
          .toList();
      final rest = syncs
          .where((e) => (e['ids'] as List).contains(id))
          .map((e) => e['atMs'] as int)
          .toList();
      var verdict = 'PASS_REALTIME';
      if (r.isEmpty) {
        verdict = 'INCONCLUSIVE_TRANSPORT';
      } else if (s.isEmpty) {
        verdict = 'FAIL_SDK_MISSING';
      } else if (s.length != 1) {
        verdict = 'FAIL_SDK_DUPLICATE';
      } else if (rest.isNotEmpty &&
          s.first >= rest.first &&
          r.first < rest.first) {
        verdict = 'FAIL_REST_FALLBACK';
      } else if (rest.isNotEmpty && rest.first <= r.first) {
        verdict = 'INCONCLUSIVE_SYNC_WON';
      } else if ((s.first - r.first).abs() > realtimeBudgetMs) {
        verdict = 'FAIL_SDK_DELAY';
      }
      rows.add({
        ...message,
        'rawMs': r,
        'sdkMs': s,
        'restMs': rest,
        'sdkMinusRawMs': r.isEmpty || s.isEmpty ? null : s.first - r.first,
        'rawMinusSendMs':
            r.isEmpty ? null : r.first - (message['sendStartMs'] as int),
        'verdict': verdict
      });
    }
    final ids = sent.map((e) => e['id']).toSet();
    Map<String, Object?> counts(List<Map<String, Object?>> events) {
      final hits = <Object?, int>{};
      for (final e in events.where((e) => ids.contains(e['id']))) {
        hits[e['id']] = (hits[e['id']] ?? 0) + 1;
      }
      return {
        'count': hits.values.fold<int>(0, (a, b) => a + b),
        'uniqueCount': hits.length,
        'missing': ids.where((id) => !hits.containsKey(id)).toList(),
        'duplicates': {
          for (final e in hits.entries)
            if (e.value > 1) '${e.key}': e.value
        },
      };
    }

    final complete = sent.length == 3 && ids.length == 3;
    final verdict = !complete || errors.isNotEmpty
        ? 'INCONCLUSIVE'
        : rows.any((r) => (r['verdict'] as String).startsWith('FAIL'))
            ? 'FAIL'
            : rows.any(
                    (r) => (r['verdict'] as String).startsWith('INCONCLUSIVE'))
                ? 'INCONCLUSIVE'
                : 'PASS';
    final result = <String, Object?>{
      'scenario': name,
      'verdict': verdict,
      'syncEnabled': !noSync,
      'roomId': roomId,
      'sentCount': sent.length,
      'sentUniqueCount': ids.length,
      'raw': counts(raw),
      'sdk': counts(sdkEvents),
      'rows': rows,
      'syncs': syncs,
      'states': states,
      'errors': errors,
    };
    event('result', result);
    return result;
  }
}

Future<void> main(List<String> args) async {
  final modes = args.where((a) => !a.startsWith('--')).toList();
  final mode = modes.isEmpty ? 'all' : modes.first;
  final summaryArgs = args.where((a) => a.startsWith('--summary=')).toList();
  if (modes.length > 1 ||
      !['all', 'before', 'after'].contains(mode) ||
      args.any((a) =>
          a.startsWith('--') &&
          a != '--no-sync' &&
          !a.startsWith('--summary=')) ||
      summaryArgs.length > 1 ||
      listenerId == senderId) {
    stderr.writeln(
        'usage: dart run tool/verify_message_subscription.dart [before|after|all] [--no-sync] [--summary=/path.json]; listener != sender');
    exit(64);
  }
  final watchdog = Timer(const Duration(minutes: 5), () {
    stderr.writeln('INCONCLUSIVE: hard run timeout');
    exit(2);
  });
  final results = <Map<String, Object?>>[];
  for (final name in mode == 'all' ? ['before', 'after'] : [mode]) {
    results.add(await Reproduction(name, args.contains('--no-sync')).run());
  }
  final summary = {
    'syncIntervalMs': syncMs,
    'realtimeBudgetMs': realtimeBudgetMs,
    'results': results
  };
  if (summaryArgs.isNotEmpty) {
    final file = File(summaryArgs.single.substring('--summary='.length));
    await file.writeAsString(
        '${const JsonEncoder.withIndent('  ').convert(summary)}\n');
  }
  print('SUMMARY ${jsonEncode(summary)}');
  watchdog.cancel();
  // SDK internal periodic streams are not all publicly disposable. Explicit
  // process exit is intentional, only after the finally cleanup above finishes.
  exit(results.any((r) => r['verdict'] == 'FAIL')
      ? 1
      : results.any((r) => r['verdict'] == 'INCONCLUSIVE')
          ? 2
          : 0);
}
