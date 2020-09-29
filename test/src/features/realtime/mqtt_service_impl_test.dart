import 'package:async/async.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/features/custom_event/custom_event.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/realtime.dart';
import 'package:test/test.dart';

class MockMqtt extends Mock implements MqttClient {}

class MockStorage extends Mock implements Storage {}

class MockLogger extends Mock implements Logger {}

class MockDio extends Mock implements Dio {}

void main() {
  MqttServiceImpl service;
  MqttClient mqtt;
  Storage storage;
  Logger logger;
  Dio dio;

  setUp(() {
    mqtt = MockMqtt();
    storage = Storage();
    logger = MockLogger();
    dio = MockDio();

    service = MqttServiceImpl(
      () => mqtt,
      storage,
      logger,
      dio,
    );
  });

  test('MqttServiceImpl.connect()', () async {
    when(mqtt.connect(any, any))
        .thenAnswer((_) => Future.value(MqttClientConnectionStatus()));

    final fn = () async => await service.connect();
    expect(fn, returnsNormally);

    verify(mqtt.connect(any, any)).called(2);
  });

  test('MqttServiceImpl.end()', () async {
    when(mqtt.disconnect()).thenReturn(null);

    var res = service.end();
    res.fold((err) => fail(err.message), (_) {});

    verify(mqtt.disconnect()).called(1);
    // verifyNoMoreInteractions(mqtt);
  });
  test('MqttServiceImpl.onConnected()', () async {
    when(mqtt.connectionStatus).thenReturn(
      MqttClientConnectionStatus()..state = MqttConnectionState.connecting,
    );

    Future.delayed(const Duration(milliseconds: 100), () async {
      when(mqtt.connectionStatus).thenReturn(
          MqttClientConnectionStatus()..state = MqttConnectionState.connected);
    });

    var stream = service.onConnected();
    var queue = StreamQueue(stream);

    await expectLater(queue, emits(true));
  });

  test('MqttServiceImpl.onDisconnected()', () async {
    when(mqtt.connectionStatus).thenReturn(
      MqttClientConnectionStatus()..state = MqttConnectionState.disconnected,
    );

    var stream = service.onDisconnected();
    var queue = StreamQueue(stream);

    await expectLater(queue, emits(true));
  });

  test('MqttServiceImpl.onReconnecting()', () async {
    when(mqtt.connectionStatus).thenReturn(
      MqttClientConnectionStatus()..state = MqttConnectionState.disconnecting,
    );

    var stream = service.onReconnecting();
    var queue = StreamQueue(stream);

    await expectLater(queue, emits(true));
  });

  test('MqttServiceImpl.synchronize()', () async {
    var resp = await service.synchronize().run();

    resp.fold(
      (err) {
        expect(err, isA<QError>());
        expect(err.message, 'Not implemented');
      },
      (data) => fail(data.toString()),
    );
  });

  test('MqttServiceImpl.synchronizeEvent()', () async {
    var resp = await service.synchronizeEvent().run();
    resp.fold(
      (err) {
        expect(err, isA<QError>());
        expect(err.message, 'Not implemented');
      },
      (data) => fail(data.toString()),
    );
  });

  test('MqttServiceImpl.publishCustomEvent()', () async {
    final event = MqttCustomEvent(
      roomId: 1,
      payload: <String, dynamic>{'key': 1},
    );

    when(mqtt.publishEvent(any)).thenReturn(right<QError, void>(null));

    var resp = service.publishCustomEvent(
      roomId: 1,
      payload: <String, dynamic>{'key': 1},
    );

    resp.fold((err) {
      fail(err.message);
    }, (_) {});

    verify(mqtt.publishEvent(event)).called(1);
  }, skip: true);

  test('MqttServiceImpl.subscribeCustomEvent()', () async {
    when(mqtt.subscribeEvent<Map<String, dynamic>, CustomEvent>(any))
        .thenAnswer(
      (_) => Stream.periodic(const Duration(milliseconds: 100), (_) {
        return CustomEvent(roomId: 1, payload: <String, dynamic>{'key': 1});
      }),
    );

    var stream = service.subscribeCustomEvent(roomId: 1);
    var queue = StreamQueue(stream);

    var event = await queue.next;

    expect(event.roomId, 1);
    expect(event.payload.keys.length, 1);
    expect(event.payload['key'], 1);
  }, skip: true);

  test('MqttServiceImpl.subscribe()', () async {
    makeStatus(mqtt, MqttConnectionState.connected);

    when(mqtt.subscribe(any, any)).thenReturn(Subscription());

    final topic = 'topic';
    var resp = await service.subscribe(topic).run();

    resp.fold((err) => fail(err.message), (_) {});

    verify(mqtt.subscribe(topic, MqttQos.atLeastOnce)).called(1);
  });

  test('MqttServiceImpl.isConnected', () async {
    makeStatus(mqtt, MqttConnectionState.connected);

    expect(service.isConnected, true);
  });

  test('MqttServiceImpl.publishPresence()', () async {
    makeStatus(mqtt, MqttConnectionState.connected);
    when(mqtt.publishMessage(
      any,
      any,
      any,
      retain: anyNamed('retain'),
    )).thenReturn(0);

    var date = DateTime.now();
    var result = service.publishPresence(
      isOnline: true,
      lastSeen: date,
      userId: 'user-id',
    );

    result.fold((err) => fail(err.message), (_) {});

    var topic = TopicBuilder.presence('user-id');
    verify(mqtt.publishMessage(
      topic,
      MqttQos.atLeastOnce,
      any,
      retain: false,
    )).called(1);
  });
  test('MqttServiceImpl.publishTyping()', () async {
    makeStatus(mqtt, MqttConnectionState.connected);
    when(mqtt.publishMessage(
      any,
      any,
      any,
      retain: anyNamed('retain'),
    )).thenReturn(0);

    var result = service.publishTyping(
      isTyping: true,
      userId: 'user-id',
      roomId: 1,
    );

    result.fold((err) => fail(err.message), (_) {});
    // var topic = TopicBuilder.typing('1', 'user-id');
    // verify(mqtt.publishMessage(
    //   topic,
    //   MqttQos.atLeastOnce,
    //   any,
    //   retain: false,
    // )).called(1);
  });
  test('MqttServiceImpl.subscribeChannelMessage()', () async {
    final channelId = 'channel-id';
    final topic = TopicBuilder.channelMessageNew('app-id', channelId);

    when(mqtt.updates).thenAnswer((_) {
      return Stream<List<MqttReceivedMessage<MqttMessage>>>.periodic(
        const Duration(milliseconds: 10),
      ).map((_) {
        return [
          MqttReceivedMessage(topic, MqttMessage()),
        ];
      });
    });

    var stream = service.subscribeChannelMessage(uniqueId: channelId);
    var queue = StreamQueue(stream);
    var data = await queue.next;

    print(data.runtimeType);
  }, timeout: Timeout(1.seconds), skip: true);
}

void makeStatus(
  MqttClient mqtt,
  MqttConnectionState state,
) {
  when(mqtt.connectionStatus).thenReturn(
    MqttClientConnectionStatus()..state = state,
  );
}
