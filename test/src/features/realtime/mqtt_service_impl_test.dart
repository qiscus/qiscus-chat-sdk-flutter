import 'dart:convert';

import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/features/custom_event/custom_event.dart';

import 'package:qiscus_chat_sdk/src/features/realtime/realtime.dart';
import 'package:qiscus_chat_sdk/src/realtime/realtime.dart';
import 'package:qiscus_chat_sdk/src/type_utils.dart';
import 'package:test/test.dart';

import '../../../utils.dart';
import 'json.dart';

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

    storage.token = 'some-token';
    storage.appId = 'app-id';

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

    verify(mqtt.connect(any, any)).called(1);
  });

  test('MqttServiceImpl.end()', () async {
    when(mqtt.disconnect()).thenReturn(null);

    await service.end();

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
    try {
      await service.synchronize();
    } catch (err) {
      expect(err, isA<QError>());
      expect(err.toString(), 'Not implemented');
    }
  });

  test('MqttServiceImpl.synchronizeEvent()', () async {
    try {
      await service.synchronizeEvent();
    } catch (err) {
      expect(err, isA<QError>());
      expect(err.toString(), 'Not implemented');
    }
  });

  test('MqttServiceImpl.publishCustomEvent()', () async {
    final event = MqttCustomEvent(
      roomId: 1,
      payload: <String, dynamic>{'key': 1},
    );

    when(mqtt.publishMessage(any, any, any)).thenReturn(1);

    await service.publishCustomEvent(
      roomId: 1,
      payload: <String, dynamic>{'key': 1},
    );

    verify(mqtt.sendEvent(event)).called(1);
  });

  test('MqttServiceImpl.subscribeCustomEvent()', () {
    var event = CustomEvent(roomId: 1, payload: <String, dynamic>{'key': 1});
    var message = makeMqttMessage(
      TopicBuilder.customEvent(event.roomId),
      jsonEncode(event.payload),
    );
    when(mqtt.updates).thenAnswer((_) => Stream.value(message));

    service.subscribeCustomEvent(roomId: 1).listen(expectAsync1((event) {
          expect(event.roomId, 1);
          expect(event.payload.keys.length, 1);
          expect(event.payload['key'], 1);
        }, count: 1));
  });

  test('MqttServiceImpl.subscribeMessageDeleted()', () {
    var topic = TopicBuilder.notification(storage.token);
    var message = makeMqttMessage(topic, jsonEncode(mqttDeleteMessageJson));

    when(mqtt.updates).thenAnswer((_) => Stream.value(message));

    service.subscribeMessageDeleted().take(1).listen(expectAsync1((data) {
          expect(data.id, Option.none());
          expect(data.uniqueId, Option.some('abc'));
        }, count: 1));
  });

  test('MqttServiceImpl.subscribeMessageDelivered()', () {
    var event = MessageDeliveredEvent(
      roomId: 1,
      userId: '123',
      messageId: 11,
      messageUniqueId: '11',
    );
    var topic = 'r/1/1/123/d';
    makeMqttMessage(topic, '${event.messageId}:${event.messageUniqueId}')(mqtt);

    service
        .subscribeMessageDelivered(roomId: event.roomId)
        .listen(expectAsync1((m) {
          expect(m.id, Option.some(event.messageId));
          expect(m.uniqueId, Option.some(event.messageUniqueId));
        }, count: 1));
  });
  test('MqttServiceImpl.subscribeMessageRead()', () {
    var event = MessageReadEvent(
      roomId: 1,
      userId: '123',
      messageId: 11,
      messageUniqueId: '11',
    );
    var topic = 'r/1/1/123/r';
    makeMqttMessage(topic, '${event.messageId}:${event.messageUniqueId}')(mqtt);

    service.subscribeMessageRead(roomId: event.roomId).listen(expectAsync1((m) {
          expect(m.id, Option.some(event.messageId));
          expect(m.uniqueId, Option.some(event.messageUniqueId));
        }, count: 1));
  });

  test('MqttServiceImpl.subscribeMessageReceived()', () {
    var topic = TopicBuilder.messageNew(storage.token);
    makeMqttMessage(topic, jsonEncode(mqttMessageJson))(mqtt);

    service.subscribeMessageReceived().listen(expectAsync1((m) {
          expect(m.id, Option.some(3326));
          expect(m.text, Option.some('Halo'));
        }, count: 1));
  });

  test('MqttServiceImpl.subscribeRoomCleared()', () {
    var topic = TopicBuilder.notification('some-token');
    makeMqttMessage(topic, jsonEncode(mqttClearRoomJson))(mqtt);

    service.subscribeRoomCleared().take(1).listen(expectAsync1((r) {
          expect(r.id, Option.some(80));
          expect(r.uniqueId, Option.none());
        }, count: 1));
  }, timeout: Timeout(1.s));

  test('MqttServiceImpl.subscribeUserPresence()', () {
    var event = UserPresenceEvent(
      userId: '123',
      lastSeen: DateTime.now(),
      isOnline: true,
    );
    var topic = TopicBuilder.presence(event.userId);

    makeMqttMessage(topic, '1:${event.lastSeen.millisecondsSinceEpoch}')(mqtt);
    service
        .subscribeUserPresence(userId: event.userId)
        .listen(expectAsync1((data) {
          expect(data.userId, event.userId);
          expect(data.isOnline, true);
          expect(data.lastSeen.millisecondsSinceEpoch,
              event.lastSeen.millisecondsSinceEpoch);
        }, count: 1));
  });

  test('MqttServiceImpl.subscribeUserTyping()', () {
    var event = UserTypingEvent(userId: '123', isTyping: true, roomId: 12);
    var topic = TopicBuilder.typing('${event.roomId}', event.userId);

    makeMqttMessage(topic, '1')(mqtt);
    service
        .subscribeUserTyping(roomId: event.roomId)
        .listen(expectAsync1((data) {
          expect(data.userId, event.userId);
          expect(data.isTyping, true);
          expect(data.roomId, event.roomId);
        }, count: 1));
  });

  test('MqttServiceImpl.subscribe()', () async {
    makeStatus(mqtt, MqttConnectionState.connected);

    when(mqtt.subscribe(any, any)).thenReturn(Subscription());

    final topic = 'topic';
    await service.subscribe(topic);

    verify(mqtt.subscribe(topic, MqttQos.atLeastOnce)).called(1);
  });
  test('MqttServiceImpl.unsubscribe()', () async {
    storage.isRealtimeEnabled = true;
    when(mqtt.unsubscribe(any)).thenReturn(null);
    when(mqtt.connectionStatus).thenReturn(
        MqttClientConnectionStatus()..state = MqttConnectionState.connected);

    await service.unsubscribe('topic');

    verify(mqtt.unsubscribe('topic')).called(1);
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
    await service.publishPresence(
      isOnline: true,
      lastSeen: date,
      userId: 'user-id',
    );

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

    await service.publishTyping(
      isTyping: true,
      userId: 'user-id',
      roomId: 1,
    );

    // var topic = TopicBuilder.typing('1', 'user-id');
    // verify(mqtt.publishMessage(
    //   topic,
    //   MqttQos.atLeastOnce,
    //   any,
    //   retain: false,
    // )).called(1);
  });

  test('MqttServiceImpl.subscribeChannelMessage()', () {
    final channelId = 'channel-id';
    final topic = TopicBuilder.channelMessageNew(storage.appId, channelId);

    var message = makeMqttMessage(topic, jsonEncode(mqttChannelJson));
    when(mqtt.updates).thenAnswer((_) => Stream.value(message));

    service
        .subscribeChannelMessage(uniqueId: channelId)
        .take(1)
        .listen(expectAsync1((data) {
          expect(data.id, Option.some(3326));
          expect(data.text, Option.some('Halo'));
        }, count: 1));
  }, timeout: Timeout(const Duration(seconds: 1)));
}

void makeStatus(
  MqttClient mqtt,
  MqttConnectionState state,
) {
  when(mqtt.connectionStatus).thenReturn(
    MqttClientConnectionStatus()..state = state,
  );
}
