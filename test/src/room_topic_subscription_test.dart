// Broker produksi (`mochi-mqtt.qiscus.com`) menolak SUBSCRIBE dengan wildcard
// untuk topic room (`r/<room>/+/+/r`, `r/<room>/<room>/+/r`, ...). Akibatnya
// receipt delivered/read dan typing tidak pernah sampai ke aplikasi. Topic per
// peserta (`r/<room>/<room>/<email>/r|d|t`) diterima. Diverifikasi live
// 13 Nov 2026 lewat widget Flutter Omnichannel + dashboard produksi.
//
// SDK mencoba wildcard dulu; topic per peserta hanya fallback per jenis topic
// yang SUBACK-nya gagal.
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

import 'support/mqtt_broker.dart';

const _me = 'customer-id';
const _agent = 'agent@example.com';
const _token = 'room-topic-token';

Map<String, Object?> _participant(String email) => {
      'email': email,
      'username': '$email-name',
      'avatar_url': 'https://example.com/a.png',
      'extras': '{}',
      'last_comment_received_id': 0,
      'last_comment_read_id': 0,
    };

Map<String, Object?> _comment(int id, {String sender = _me}) => {
      ...mqttComment(id),
      'email': sender,
      'username': '$sender-name',
    };

class _Fixture {
  _Fixture(this.broker) {
    sdk.storage
      ..appId = 'loopback-test'
      ..brokerUrl = '127.0.0.1'
      ..isSyncEnabled = false;
    (sdk.mqtt as MqttServerClient)
      ..secure = false
      ..port = broker.port
      ..keepAlivePeriod = 0;
    sdk.dio.interceptors.add(InterceptorsWrapper(onRequest: (request, handler) {
      final path = request.path.split('?').first;
      paths.add(path);
      final data = _respond(path);
      if (data == null) {
        handler.reject(DioException(requestOptions: request, error: 'HTTP $path'));
        return;
      }
      handler.resolve(Response<Map<String, Object?>>(
          requestOptions: request, statusCode: 200, data: data));
    }));
  }

  final TestMqttBroker broker;
  final sdk = QiscusSDK();
  final paths = <String>[];
  final subscriptions = <StreamSubscription<dynamic>>[];

  /// Peserta di respons `get_room_by_id`.
  List<String> roomParticipants = [_me, _agent];

  /// Peserta di respons `room_participants`; `null` = endpoint gagal.
  List<String>? apiParticipants;

  List<Map<String, Object?>> comments = [];

  Map<String, Object?>? _respond(String path) {
    switch (path) {
      case 'login_or_register':
        return {
          'results': {
            'user': {
              'email': _me,
              'username': 'me',
              'avatar_url': 'https://example.com/a.png',
              'last_comment_id': 0,
              'last_sync_event_id': 0,
              'extras': '{}',
              'token': _token,
            }
          }
        };
      case 'get_room_by_id':
        return {
          'results': {
            'room': {
              'id': 1,
              'room_name': 'room',
              'unique_id': 'room-unique-id',
              'unread_count': 0,
              'avatar_url': 'https://example.com/a.png',
              'options': '{}',
              'chat_type': 'single',
              'is_public_channel': false,
              'participants': roomParticipants.map(_participant).toList(),
            },
            'comments': comments,
          }
        };
      case 'room_participants':
        final ids = apiParticipants;
        if (ids == null) return null;
        return {
          'results': {'participants': ids.map(_participant).toList()}
        };
      case 'add_room_participants':
        return {
          'results': {
            'participants_added': [_participant('new@example.com')]
          }
        };
      case 'remove_room_participants':
        return {
          'results': {
            'participants_removed': [_agent]
          }
        };
      case 'update_comment_status':
        return {'results': <String, Object?>{}};
    }
    return null;
  }

  Future<void> login() async {
    await sdk.setUser(userId: _me, userKey: 'key');
    await waitFor(() =>
        sdk.mqtt.connectionStatus?.state == MqttConnectionState.connected &&
        sdk.mqtt.getSubscriptionsStatus('$_token/c') ==
            MqttSubscriptionStatus.active);
  }

  Future<void> close() async {
    await Future.wait(subscriptions.map((it) => it.cancel()))
        .timeout(const Duration(seconds: 2));
    sdk.mqtt.autoReconnect = false;
    await sdk.clearUser();
    sdk.dio.close(force: true);
    await broker.close();
  }
}

Future<_Fixture> _start({bool Function(String)? reject}) async {
  final fixture = _Fixture(await TestMqttBroker.start(rejectSubscribe: reject));
  addTearDown(fixture.close);
  await fixture.login();
  return fixture;
}

const _reject = TestMqttBroker.rejectRoomWildcards;

const _wildcards = ['r/1/+/+/r', 'r/1/+/+/d', 'r/1/1/+/t'];

const _agentTopics = [
  'r/1/1/$_agent/r',
  'r/1/1/$_agent/d',
  'r/1/1/$_agent/t',
];

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 200));

void main() {
  test('uses only the wildcard filters when the broker accepts them', () async {
    final fixture = await _start();
    fixture.roomParticipants = [];
    final data = await fixture.sdk.getChatRoomWithMessages(roomId: 1);

    fixture.sdk.subscribeChatRoom(data.room);
    await waitFor(() => _wildcards.every(fixture.broker.subscribed));
    await _settle();

    expect(_agentTopics.any(fixture.broker.subscribed), isFalse);
    expect(fixture.paths, isNot(contains('room_participants')),
        reason: 'participants are only needed for the fallback');
  });

  test('falls back to one topic per other participant when SUBACK fails',
      () async {
    final fixture = await _start(reject: _reject);
    final data = await fixture.sdk.getChatRoomWithMessages(roomId: 1);

    fixture.sdk.subscribeChatRoom(data.room);
    await waitFor(() => _agentTopics.every(fixture.broker.subscribed));

    expect(fixture.broker.rejected, unorderedEquals(_wildcards));
    expect(fixture.broker.subscribed('r/1/1/$_me/r'), isFalse);
  });

  test('receipts and typing reach the SDK streams once after the fallback',
      () async {
    final fixture = await _start(reject: _reject);
    fixture.comments = [_comment(4), _comment(5)];
    final data = await fixture.sdk.getChatRoomWithMessages(roomId: 1);
    final read = <int>[], delivered = <int>[], typing = <String>[];
    fixture.subscriptions.addAll([
      fixture.sdk.onMessageRead().listen((m) => read.add(m.id)),
      fixture.sdk.onMessageDelivered().listen((m) => delivered.add(m.id)),
      fixture.sdk.onUserTyping().listen((t) => typing.add(t.userId)),
    ]);

    fixture.sdk.subscribeChatRoom(data.room);
    await waitFor(() => _agentTopics.every(fixture.broker.subscribed));
    await fixture.broker.publishRaw('r/1/1/$_agent/d', '4:unique-4');
    await fixture.broker.publishRaw('r/1/1/$_agent/t', '1');
    await fixture.broker.publishRaw('r/1/1/$_agent/r', '5:unique-5');

    await waitFor(() => read.length == 2 && typing.isNotEmpty);
    await _settle();
    expect(delivered, [4]);
    expect(read, [4, 5]);
    expect(typing, [_agent]);
  });

  test('only the rejected kind falls back; events from both kinds share the '
      'same handlers', () async {
    final fixture =
        await _start(reject: (filter) => filter == 'r/1/+/+/r');
    fixture.comments = [_comment(4), _comment(5)];
    final data = await fixture.sdk.getChatRoomWithMessages(roomId: 1);
    final read = <int>[], delivered = <int>[];
    fixture.subscriptions.addAll([
      fixture.sdk.onMessageRead().listen((m) => read.add(m.id)),
      fixture.sdk.onMessageDelivered().listen((m) => delivered.add(m.id)),
    ]);

    fixture.sdk.subscribeChatRoom(data.room);
    await waitFor(() =>
        fixture.broker.subscribed('r/1/1/$_agent/r') &&
        fixture.broker.subscribed('r/1/+/+/d'));
    expect(fixture.broker.subscribed('r/1/1/$_agent/d'), isFalse);

    // delivered lewat wildcard, read lewat topic per peserta.
    await fixture.broker.publishRaw('r/1/1/$_agent/d', '4:unique-4',
        filter: 'r/1/+/+/d');
    await fixture.broker.publishRaw('r/1/1/$_agent/r', '5:unique-5');

    await waitFor(() => read.length == 2);
    await _settle();
    expect(delivered, [4]);
    expect(read, [4, 5]);
  });

  test('fetches participants for the fallback when the room has none',
      () async {
    final fixture = await _start(reject: _reject);
    fixture
      ..roomParticipants = []
      ..apiParticipants = [_me, _agent];
    final data = await fixture.sdk.getChatRoomWithMessages(roomId: 1);

    fixture.sdk.subscribeChatRoom(data.room);
    await waitFor(() => _agentTopics.every(fixture.broker.subscribed));
    expect(fixture.paths.where((p) => p == 'room_participants'), hasLength(1));
  });

  test('a failed participant fetch leaves the room without topics, no error',
      () async {
    final fixture = await _start(reject: _reject);
    fixture
      ..roomParticipants = []
      ..apiParticipants = null;
    final errors = <Object>[];
    final data = await runZonedGuarded(
        () => fixture.sdk.getChatRoomWithMessages(roomId: 1),
        (e, _) => errors.add(e))!;

    runZonedGuarded(() => fixture.sdk.subscribeChatRoom(data.room),
        (e, _) => errors.add(e));
    await waitFor(() => fixture.broker.rejected.length == 3);
    await _settle();
    expect(errors, isEmpty);
    expect(_agentTopics.any(fixture.broker.subscribed), isFalse);
  });

  test('unsubscribeChatRoom releases exactly the subscribed topics', () async {
    final fixture = await _start(reject: _reject);
    final data = await fixture.sdk.getChatRoomWithMessages(roomId: 1);
    fixture.sdk.subscribeChatRoom(data.room);
    await waitFor(() => _agentTopics.every(fixture.broker.subscribed));

    fixture.sdk.unsubscribeChatRoom(data.room);
    await waitFor(() => !_agentTopics.any(fixture.broker.subscribed));
  });

  test('add/removeParticipants update the fallback topics', () async {
    final fixture = await _start(reject: _reject);
    final data = await fixture.sdk.getChatRoomWithMessages(roomId: 1);
    fixture.sdk.subscribeChatRoom(data.room);
    await waitFor(() => _agentTopics.every(fixture.broker.subscribed));

    await fixture.sdk
        .addParticipants(roomId: 1, userIds: ['new@example.com']);
    await waitFor(
        () => fixture.broker.subscribed('r/1/1/new@example.com/r'));

    await fixture.sdk.removeParticipants(roomId: 1, userIds: [_agent]);
    await waitFor(() => !_agentTopics.any(fixture.broker.subscribed));
    expect(fixture.broker.subscribed('r/1/1/new@example.com/d'), isTrue);
  });

  test('wildcard rejections handled by the fallback are not realtime errors; '
      'a rejected fallback topic is', () async {
    final fixture = await _start(
        reject: (f) => _reject(f) || f == 'r/1/1/$_agent/t');
    final errors = <Object>[];
    fixture.subscriptions
        .add(fixture.sdk.realtimeErrors$.stream.listen(errors.add));
    final data = await fixture.sdk.getChatRoomWithMessages(roomId: 1);

    fixture.sdk.subscribeChatRoom(data.room);
    await waitFor(() =>
        fixture.broker.subscribed('r/1/1/$_agent/r') &&
        fixture.broker.subscribed('r/1/1/$_agent/d') &&
        errors.isNotEmpty);
    await _settle();

    expect(errors, hasLength(1));
    // Topic per peserta memuat email: tetap disamarkan di pesan error.
    expect('${errors.single}', contains('[redacted]'));
    expect('${errors.single}', isNot(contains(_agent)));
  });

  test('participant ids that are not valid in a topic are skipped', () async {
    final fixture = await _start(reject: _reject);
    fixture.roomParticipants = [_me, _agent, 'bad+id@example.com'];
    final data = await fixture.sdk.getChatRoomWithMessages(roomId: 1);

    fixture.sdk.subscribeChatRoom(data.room);
    await waitFor(() => _agentTopics.every(fixture.broker.subscribed));
    await _settle();
    expect(fixture.broker.rejected, unorderedEquals(_wildcards));
  });
}
