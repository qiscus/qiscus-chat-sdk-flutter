// Regresi bug status Klikdokter: event delivered/read (dan deleted) dibuang
// diam-diam bila pesannya tidak ada di `Storage.messages`. Store itu dulu hanya
// diisi oleh `sendMessage`/`updateMessage`, jadi setelah aplikasi restart
// status pesan milik user sendiri tidak pernah ter-update lewat event.
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/impls/message/message-from-json-impl.dart';
import 'package:qiscus_chat_sdk/src/impls/message/on-message-deleted-impl.dart';
import 'package:qiscus_chat_sdk/src/impls/sync.dart';
import 'package:test/test.dart';

import 'support/mqtt_broker.dart';

const _userId = 'listener-id';
const _token = 'loopback-token';

Map<String, Object?> _comment(int id, {String sender = _userId}) => {
      ...mqttComment(id),
      'email': sender,
      'username': '$sender-name',
    };

Map<String, Object?> _room() => {
      'id': 1,
      'room_name': 'room',
      'unique_id': 'room-unique-id',
      'unread_count': 0,
      'avatar_url': 'https://example.com/avatar.png',
      'options': '{}',
      'chat_type': 'single',
      'is_public_channel': false,
      'participants': <Object?>[],
    };

class _Fixture {
  _Fixture(this.broker) {
    sdk.storage
      ..appId = 'loopback-test'
      ..brokerUrl = '127.0.0.1'
      ..isSyncEnabled = false;
    final mqtt = sdk.mqtt as MqttServerClient;
    mqtt
      ..secure = false
      ..port = broker.port
      ..keepAlivePeriod = 0;
    sdk.dio.interceptors.add(InterceptorsWrapper(onRequest: (request, handler) {
      final data = _respond(request);
      if (data == null) {
        handler.reject(DioException(
            requestOptions: request, error: 'Unexpected HTTP ${request.path}'));
        return;
      }
      handler.resolve(Response<Map<String, Object?>>(
          requestOptions: request, statusCode: 200, data: data));
    }));
  }

  final TestMqttBroker broker;
  final sdk = QiscusSDK();
  final subscriptions = <StreamSubscription<dynamic>>[];

  /// Komentar yang dikembalikan oleh `get_room_by_id` dan `load_comments`.
  List<Map<String, Object?>> comments = [];

  Map<String, Object?>? _respond(RequestOptions request) {
    // GET membawa query di path (mis. `get_room_by_id?id=1`).
    switch (request.path.split('?').first) {
      case 'login_or_register':
        return {
          'results': {
            'user': {
              'email': _userId,
              'username': 'listener-name',
              'avatar_url': 'https://example.com/avatar.png',
              'last_comment_id': 0,
              'last_sync_event_id': 0,
              'extras': '{}',
              'token': _token,
            }
          }
        };
      case 'get_room_by_id':
        return {
          'results': {'room': _room(), 'comments': comments}
        };
      case 'load_comments':
        return {
          'results': {'comments': comments}
        };
      case 'post_comment':
        final body = request.data as Map<String, dynamic>;
        return {
          'results': {
            'comment': {
              ..._comment(9),
              'unique_temp_id': body['unique_temp_id'],
            }
          }
        };
      case 'update_comment_status':
        return {'results': <String, Object?>{}};
    }
    return null;
  }

  List<QMessage> collect(Stream<QMessage> stream) {
    final items = <QMessage>[];
    subscriptions.add(stream.listen(items.add));
    return items;
  }

  Future<void> login() async {
    await sdk.setUser(userId: _userId, userKey: 'test-user-key');
    await waitFor(() =>
        sdk.mqtt.connectionStatus?.state == MqttConnectionState.connected &&
        sdk.mqtt.getSubscriptionsStatus('$_token/c') ==
            MqttSubscriptionStatus.active &&
        sdk.mqtt.getSubscriptionsStatus('$_token/n') ==
            MqttSubscriptionStatus.active);
  }

  Future<void> subscribeRoom(QChatRoom room) async {
    sdk.subscribeChatRoom(room);
    await waitFor(
        () => broker.subscribed('r/1/+/+/d') && broker.subscribed('r/1/+/+/r'));
  }

  Future<void> receipt(String kind, int id, {String by = 'other-user'}) {
    return broker.publishRaw('r/1/$id/$by/$kind', '$id:unique-$id',
        filter: 'r/1/+/+/$kind');
  }

  Future<void> close() async {
    // Jangan di-await: `cancel()` pada stream delivered/read tidak pernah
    // selesai (sudah begitu sebelum perbaikan ini; `_synchronizeEvent()`).
    for (final subscription in subscriptions) {
      unawaited(subscription.cancel());
    }
    sdk.mqtt.autoReconnect = false;
    await sdk.clearUser();
    sdk.dio.close(force: true);
    await sdk.realtimeErrors$.close();
    await broker.close();
  }
}

QMessage _message(int id, {QMessageStatus status = QMessageStatus.sent}) {
  return messageFromJson(_comment(id))..status = status;
}

void main() {
  group('status events for messages loaded from the server', () {
    test('delivered and read are emitted for an own message from room load',
        () async {
      final fixture = _Fixture(await TestMqttBroker.start());
      addTearDown(fixture.close);
      final delivered = fixture.collect(fixture.sdk.onMessageDelivered());
      final read = fixture.collect(fixture.sdk.onMessageRead());
      await fixture.login();

      // Proses baru: belum ada pesan yang dikirim, pesan hanya dimuat.
      fixture.comments = [_comment(5)];
      final data = await fixture.sdk.getChatRoomWithMessages(roomId: 1);
      expect(data.messages.single.status, QMessageStatus.sent);
      await fixture.subscribeRoom(data.room);

      await fixture.receipt('d', 5);
      await waitFor(() => delivered.isNotEmpty);
      expect(delivered.single.id, 5);
      expect(delivered.single.status, QMessageStatus.delivered);

      await fixture.receipt('r', 5);
      await waitFor(() => read.isNotEmpty);
      expect(read.single.id, 5);
      expect(read.single.status, QMessageStatus.read);
    });

    test('a late delivered event never downgrades a read message', () async {
      final fixture = _Fixture(await TestMqttBroker.start());
      addTearDown(fixture.close);
      final delivered = fixture.collect(fixture.sdk.onMessageDelivered());
      final read = fixture.collect(fixture.sdk.onMessageRead());
      await fixture.login();

      fixture.comments = [_comment(5)];
      final data = await fixture.sdk.getChatRoomWithMessages(roomId: 1);
      await fixture.subscribeRoom(data.room);

      await fixture.receipt('r', 5);
      await waitFor(() => read.isNotEmpty);
      await fixture.receipt('d', 5);
      await waitFor(() => delivered.isNotEmpty);

      expect(delivered.single.status, QMessageStatus.read);
      expect(data.messages.single.status, QMessageStatus.read);
    });

    test('next and previous message loaders register messages too', () async {
      final fixture = _Fixture(await TestMqttBroker.start());
      addTearDown(fixture.close);
      final delivered = fixture.collect(fixture.sdk.onMessageDelivered());
      await fixture.login();

      fixture.comments = [];
      final data = await fixture.sdk.getChatRoomWithMessages(roomId: 1);
      await fixture.subscribeRoom(data.room);

      fixture.comments = [_comment(6)];
      final next =
          await fixture.sdk.getNextMessagesById(roomId: 1, messageId: 5);
      fixture.comments = [_comment(4)];
      final previous =
          await fixture.sdk.getPreviousMessagesById(roomId: 1, messageId: 5);

      await fixture.receipt('d', 6);
      await fixture.receipt('d', 4);
      await waitFor(() => delivered.length == 2);
      expect(delivered.map((m) => m.id), [6, 4]);
      // Instance yang dikembalikan ke aplikasi adalah instance yang di-update.
      expect(identical(delivered[0], next.single), isTrue);
      expect(identical(delivered[1], previous.single), isTrue);
    });

    test('loading the same message twice keeps a single store entry', () async {
      final fixture = _Fixture(await TestMqttBroker.start());
      addTearDown(fixture.close);
      final delivered = fixture.collect(fixture.sdk.onMessageDelivered());
      await fixture.login();

      fixture.comments = [_comment(5)];
      await fixture.sdk.getChatRoomWithMessages(roomId: 1);
      final second = await fixture.sdk.getChatRoomWithMessages(roomId: 1);
      await fixture.sdk.getPreviousMessagesById(roomId: 1, messageId: 6);

      final stored = fixture.sdk.storage.messages.where((m) => m.id == 5);
      expect(stored, hasLength(1));

      await fixture.subscribeRoom(second.room);
      await fixture.receipt('d', 5);
      await waitFor(() => delivered.isNotEmpty);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(delivered, hasLength(1));
    });

    test('receipts for messages of other users are not emitted', () async {
      final fixture = _Fixture(await TestMqttBroker.start());
      addTearDown(fixture.close);
      final delivered = fixture.collect(fixture.sdk.onMessageDelivered());
      await fixture.login();

      fixture.comments = [_comment(5, sender: 'other-user'), _comment(6)];
      final data = await fixture.sdk.getChatRoomWithMessages(roomId: 1);
      await fixture.subscribeRoom(data.room);

      // Receipt dari user sendiri atas pesan orang lain (mis. markAsDelivered
      // otomatis) tidak boleh muncul sebagai status pesan.
      await fixture.receipt('d', 5, by: _userId);
      await fixture.receipt('d', 6);
      await waitFor(() => delivered.isNotEmpty);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(delivered.map((m) => m.id), [6]);
    });

    test('sendMessage still gets status events', () async {
      final fixture = _Fixture(await TestMqttBroker.start());
      addTearDown(fixture.close);
      final delivered = fixture.collect(fixture.sdk.onMessageDelivered());
      await fixture.login();

      final data = await fixture.sdk.getChatRoomWithMessages(roomId: 1);
      await fixture.subscribeRoom(data.room);
      final sent = await fixture.sdk.sendMessage(
        message: fixture.sdk.generateMessage(chatRoomId: 1, text: 'hi'),
      );
      expect(sent.id, 9);

      await fixture.broker.publishRaw(
          'r/1/9/other-user/d', '9:${sent.uniqueId}',
          filter: 'r/1/+/+/d');
      await waitFor(() => delivered.isNotEmpty);
      expect(delivered.single.id, 9);
      expect(delivered.single.status, QMessageStatus.delivered);
    });
  });

  test('a message from onMessageReceived can later be deleted', () async {
    final fixture = _Fixture(await TestMqttBroker.start());
    addTearDown(fixture.close);
    final received = fixture.collect(fixture.sdk.onMessageReceived());
    final deleted = fixture.collect(fixture.sdk.onMessageDeleted());
    await fixture.login();

    await fixture.broker
        .publish('$_token/c', _comment(7, sender: 'other-user'));
    await waitFor(() => received.isNotEmpty);

    await fixture.broker.publish('$_token/n', {
      'action_topic': 'delete_message',
      'payload': {
        'data': {
          'deleted_messages': [
            {
              'room_id': '1',
              'message_unique_ids': ['unique-7'],
            }
          ],
        },
      },
    });
    await waitFor(() => deleted.isNotEmpty);
    expect(deleted.single.id, 7);
    expect(fixture.sdk.storage.messages.where((m) => m.id == 7), isEmpty);
  });

  group('Storage.messages', () {
    test('is bounded and evicts the oldest entries', () {
      final storage = Storage();
      storage.messages = {for (var id = 1; id <= 2500; id++) _message(id)};

      expect(storage.messages, hasLength(maxStoredMessages));
      expect(storage.messages.first.id, 501);
      expect(storage.messages.last.id, 2500);

      storage.messages = {...storage.messages, _message(2501)};
      expect(storage.messages, hasLength(maxStoredMessages));
      expect(storage.messages.first.id, 502);
    });

    test('dedupes by id and uniqueId, newest instance wins', () {
      final storage = Storage();
      final first = _message(5);
      final again = _message(5);
      final sameUniqueId = _message(6)..uniqueId = 'unique-5';
      storage.messages = {first, _message(4), again};

      expect(storage.messages.map((m) => m.id), [4, 5]);
      expect(identical(storage.messages.last, again), isTrue);

      storage.messages = {...storage.messages, sameUniqueId};
      expect(storage.messages.map((m) => m.id), [4, 6]);
    });

    test('a replacing instance never lowers the known status', () {
      final storage = Storage();
      storage.messages = {_message(5, status: QMessageStatus.read)};
      final reloaded = _message(5, status: QMessageStatus.delivered);
      storage.messages = {...storage.messages, reloaded};

      expect(storage.messages.single, same(reloaded));
      expect(reloaded.status, QMessageStatus.read);
    });

    test('clear() empties the store', () {
      final storage = Storage()..messages = {_message(1)};
      storage.clear();
      expect(storage.messages, isEmpty);
    });
  });

  group('sync event deleted transformer', () {
    Future<List<QMessage?>> run(QRealtimeEvent event) {
      return Stream<QRealtimeEvent>.value(event)
          .transform(syncMessageDeletedTransformerImpl)
          .map((state) => state.run([_message(5)]).first)
          .toList();
    }

    test('a delivered event is not treated as a deletion', () async {
      final result = await run(MessageDeliveredEvent(
        userId: 'other-user',
        roomId: 1,
        messageId: 5,
        messageUniqueId: 'unique-5',
      ));
      expect(result.whereType<QMessage>(), isEmpty);
    });

    test('a deleted event emits the stored message', () async {
      final result = await run(
        MessageDeletedEvent(roomId: 1, messageUniqueId: 'unique-5'),
      );
      expect(result.single?.id, 5);
    });

    test('a deleted event for an unknown message yields null', () async {
      final result = await run(
        MessageDeletedEvent(roomId: 1, messageUniqueId: 'unique-404'),
      );
      expect(result, [null]);
    });
  });
}
