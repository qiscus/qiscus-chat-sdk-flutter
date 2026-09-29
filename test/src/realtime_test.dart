import 'dart:async';

import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/domains.dart';
import 'package:qiscus_chat_sdk/src/impls/message/message-from-json-impl.dart';
import 'package:qiscus_chat_sdk/src/realtime.dart';
import 'package:test/test.dart';

import 'dio_mock.dart';

class RealtimeHost with QRealtimeService {
  RealtimeHost(this.mqtt, this.storage, this.dio);

  @override
  final MqttClient mqtt;
  @override
  final Storage storage;
  @override
  final Dio dio;
}

/// `updates` selalu null, jadi jalur realtime tidak pernah menghasilkan apa
/// pun - test ini khusus menguji jalur cadangan sinkronisasi REST.
class DeadMqttClient extends MqttClient {
  DeadMqttClient() : super('localhost', 'test-client');

  @override
  Stream<List<MqttReceivedMessage<MqttMessage>>>? get updates => null;
}

Json _syncResponse(int messageId) => <String, Object?>{
      'results': <String, Object?>{
        'meta': <String, Object?>{'last_received_comment_id': messageId},
        'comments': <Json>[
          <String, Object?>{
            'id': messageId,
            'room_id': 1,
            'comment_before_id': messageId - 1,
            'unique_temp_id': 'unique-$messageId',
            'message': 'hello',
            'type': 'text',
            'status': 'sent',
            'unix_nano_timestamp': 1600000000000000000,
            'email': 'sender-id',
            'username': 'sender-name',
            'user_avatar_url': 'https://example.com/avatar.png',
          },
        ],
      },
    };

/// Satu komentar sync dengan timestamp `id` detik setelah epoch dasar, kecuali
/// [timestampSeconds] diberikan.
Json _commentJson(int id, {int? timestampSeconds}) => <String, Object?>{
      'id': id,
      'room_id': 1,
      'comment_before_id': id - 1,
      'unique_temp_id': 'unique-$id',
      'message': 'message-$id',
      'type': 'text',
      'status': 'sent',
      'unix_nano_timestamp':
          1600000000000000000 + (timestampSeconds ?? id) * 1000000000,
      'email': 'sender-id',
      'username': 'sender-name',
      'user_avatar_url': 'https://example.com/avatar.png',
    };

/// Respons `sync` berisi [comments] sesuai urutan yang diberikan (server
/// mengirim urutan menurun), dengan cursor server = [lastId].
Json _syncBatch(List<Json> comments, {required int lastId}) =>
    <String, Object?>{
      'results': <String, Object?>{
        'meta': <String, Object?>{'last_received_comment_id': lastId},
        'comments': comments,
      },
    };

Storage _loggedInStorage() {
  return _fastStorage()
    ..currentUser = QAccount(id: 'user-id', name: 'user-name')
    ..token = 'a-token';
}

void _stubSync(MockDio dio, Json response) {
  when(dio.request<Json>(
    any,
    options: anyNamed('options'),
    data: anyNamed('data'),
    queryParameters: anyNamed('queryParameters'),
  )).thenAnswer((_) async {
    return Response<Json>(
      requestOptions: RequestOptions(path: 'sync'),
      data: response,
    );
  });
}

Storage _fastStorage() {
  return Storage()
    ..syncInterval = const Duration(milliseconds: 100)
    ..syncIntervalWhenConnected = const Duration(milliseconds: 100)
    ..accSyncInterval = const Duration(milliseconds: 100)
    ..isSyncEnabled = true;
}

Stream<QMessage> _messageStream(
  RealtimeHost host, {
  StreamController<QMessage>? subs,
}) {
  return host.getMessageReceivedStream(
    messageReceivedSubs$: subs ?? StreamController<QMessage>.broadcast(),
    markAsDelivered: ({required int roomId, required int messageId}) async {},
    triggerHook: <T>(QInterceptor _, T data) async => data,
  );
}

void main() {
  // Ini regresi utama bug realtime Klikdokter. `_synchronize()` dulu membaca
  // `storage.isLogin` sekali di luar loop `await for`. Stream ini dibuat saat
  // aplikasi memasang listener `onMessageReceived()`, yang pada mayoritas
  // aplikasi terjadi SEBELUM `setUser()` selesai - jadi nilainya terkunci
  // `false` selamanya dan sinkronisasi REST tidak pernah jalan seumur hidup
  // proses.
  test('synchronize picks up a login that happens after the stream is created',
      () async {
    var dio = MockDio();
    _stubSync(dio, _syncResponse(42));

    var storage = _fastStorage();
    var host = RealtimeHost(DeadMqttClient(), storage, dio);

    // Belum login saat stream dibuat - persis seperti urutan di aplikasi.
    expect(storage.isLogin, isFalse);
    var messages = _messageStream(host);
    var first = messages.first;

    await Future<void>.delayed(const Duration(milliseconds: 50));
    storage.currentUser = QAccount(id: 'user-id', name: 'user-name');
    storage.token = 'a-token';
    expect(storage.isLogin, isTrue);

    var message = await first.timeout(const Duration(seconds: 5));
    expect(message.id, 42);
    expect(message.text, 'hello');
  });

  test('synchronize stays idle while the user is not logged in', () async {
    var dio = MockDio();
    _stubSync(dio, _syncResponse(42));

    var host = RealtimeHost(DeadMqttClient(), _fastStorage(), dio);
    var received = <QMessage>[];
    var subs = _messageStream(host).listen(received.add);
    addTearDown(subs.cancel);

    await Future<void>.delayed(const Duration(milliseconds: 800));
    expect(received, isEmpty);
  });

  // Root cause #4: kedua jalur sync dulu menelan semua error dengan
  // `catch (_) {}`, jadi aplikasi tidak punya cara tahu jalur cadangannya
  // sendiri sedang gagal.
  test('synchronize reports failures on realtimeErrors\$', () async {
    var dio = MockDio();
    when(dio.request<Json>(
      any,
      options: anyNamed('options'),
      data: anyNamed('data'),
      queryParameters: anyNamed('queryParameters'),
    )).thenThrow(StateError('boom'));

    var storage = _fastStorage();
    storage.currentUser = QAccount(id: 'user-id', name: 'user-name');
    storage.token = 'a-token';

    var host = RealtimeHost(DeadMqttClient(), storage, dio);
    var firstError = host.realtimeErrors$.stream.first;

    var subs = _messageStream(host).listen((_) {});
    addTearDown(subs.cancel);

    var error = await firstError.timeout(const Duration(seconds: 5));
    expect(error.message, contains('Message synchronization failed'));
  });
  // Bug urutan/dobel Klikdokter (tiket 23144): `distinct` hanya membuang
  // duplikat yang BERURUTAN, dan cursor `lastMessageId` bisa mundur.
  group('message order and duplicates', () {
    test('sync batch is delivered oldest first by timestamp', () async {
      var dio = MockDio();
      // Server mengirim urutan menurun 12 -> 1.
      var batch = _syncBatch(
        [for (var id = 12; id >= 1; id--) _commentJson(id)],
        lastId: 12,
      );
      _stubSync(dio, batch);

      var host = RealtimeHost(DeadMqttClient(), _loggedInStorage(), dio);
      var received = await _messageStream(host)
          .take(12)
          .toList()
          .timeout(const Duration(seconds: 5));

      expect(received.map((m) => m.id), [for (var id = 1; id <= 12; id++) id]);
    });

    test('sync batch is sorted by timestamp, not by id', () async {
      var dio = MockDio();
      // id 2 lebih lama daripada id 1; dua pesan lain punya timestamp sama.
      var batch = _syncBatch([
        _commentJson(1, timestampSeconds: 50),
        _commentJson(2, timestampSeconds: 40),
        _commentJson(4, timestampSeconds: 60),
        _commentJson(3, timestampSeconds: 60),
      ], lastId: 4);
      _stubSync(dio, batch);

      var host = RealtimeHost(DeadMqttClient(), _loggedInStorage(), dio);
      var received = await _messageStream(host)
          .take(4)
          .toList()
          .timeout(const Duration(seconds: 5));

      // Timestamp sama (3 dan 4) -> id hanya sebagai penentu urutan tetap.
      expect(received.map((m) => m.id), [2, 1, 3, 4]);
    });

    test('a resent sync batch is not delivered twice', () async {
      var dio = MockDio();
      var batch = _syncBatch(
        [for (var id = 12; id >= 1; id--) _commentJson(id)],
        lastId: 12,
      );
      // Stub selalu mengembalikan batch yang sama, seperti siklus sync yang
      // menarik ulang pesan yang sudah diterima.
      _stubSync(dio, batch);

      var host = RealtimeHost(DeadMqttClient(), _loggedInStorage(), dio);
      var received = <int>[];
      var subs = _messageStream(host).listen((m) => received.add(m.id));
      addTearDown(subs.cancel);

      await Future<void>.delayed(const Duration(milliseconds: 900));
      expect(received, [for (var id = 1; id <= 12; id++) id]);
    });

    test('sync keeps the cursor at the newest id after a descending batch',
        () async {
      var dio = MockDio();
      var batch = _syncBatch(
        [for (var id = 12; id >= 1; id--) _commentJson(id)],
        lastId: 12,
      );
      _stubSync(dio, batch);

      var storage = _loggedInStorage();
      var host = RealtimeHost(DeadMqttClient(), storage, dio);
      await _messageStream(host)
          .take(12)
          .toList()
          .timeout(const Duration(seconds: 5));

      expect(storage.lastMessageId, 12);
      expect(storage.currentUser?.lastMessageId, 12);
    });

    test('out-of-order and repeated messages are deduplicated by id',
        () async {
      var subs$ = StreamController<QMessage>.broadcast();
      var storage = _fastStorage();
      var host = RealtimeHost(DeadMqttClient(), storage, MockDio());
      var received = <int>[];
      var subs = _messageStream(host, subs: subs$).listen(
        (m) => received.add(m.id),
      );
      addTearDown(subs.cancel);
      addTearDown(subs$.close);

      // Urutan persis dari reproduksi produksi (28 September).
      for (var id in [5, 7, 6, 8, 10, 9, 6]) {
        subs$.add(messageFromJson(_commentJson(id)));
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(received, [5, 7, 6, 8, 10, 9]);
      expect(storage.lastMessageId, 10);
    });

    test('cursor never moves backwards when a message arrives late', () async {
      var subs$ = StreamController<QMessage>.broadcast();
      var storage = _fastStorage();
      var host = RealtimeHost(DeadMqttClient(), storage, MockDio());
      var subs = _messageStream(host, subs: subs$).listen((_) {});
      addTearDown(subs.cancel);
      addTearDown(subs$.close);

      for (var id in [7, 9, 8]) {
        subs$.add(messageFromJson(_commentJson(id)));
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(storage.lastMessageId, 9);
    });

    test('Storage.setLastMessageId only moves forward', () {
      var storage = Storage()
        ..currentUser = QAccount(id: 'user-id', name: 'user-name');

      storage.setLastMessageId(9);
      storage.setLastMessageId(8);
      expect(storage.lastMessageId, 9);
      expect(storage.currentUser?.lastMessageId, 9);

      storage.setLastMessageId(10);
      expect(storage.lastMessageId, 10);
      expect(storage.currentUser?.lastMessageId, 10);
    });
  });
}
