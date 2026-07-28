import 'dart:async';

import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/domains.dart';
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

Stream<QMessage> _messageStream(RealtimeHost host) {
  return host.getMessageReceivedStream(
    messageReceivedSubs$: StreamController<QMessage>.broadcast(),
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
}
