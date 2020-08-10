import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'features/message/message.dart';
import 'features/user/user.dart';

/// Known sync & sync_event topic
enum _SyncTopic {
  // from sync
  messageReceived,
  // from sync_event
  messageRead,
  messageDelivered,
  messageDeleted,
  roomCleared,
}

mixin IRealtimeEvent<Output extends Object> {
  /// mqtt topic which this event should subscribe
  Option<String> get mqttTopic;

  /// mqtt data which this event will send
  Option<String> get mqttData;

  /// sync topic which this event should listen
  Option<_SyncTopic> get syncTopic;

  Stream<Output> mqttMapper(String payload);
  Stream<Output> syncMapper(Map<String, dynamic> payload);
}

class UserTypingEvent with IRealtimeEvent<UserTyping> {
  UserTypingEvent({
    @required this.roomId,
    String userId,
    bool isTyping,
  })  : userId = optionOf(userId),
        isTyping = optionOf(isTyping);

  final int roomId;
  final Option<String> userId;
  final Option<bool> isTyping;

  get mqttTopic => some('r/$roomId/+/+/t');
  get mqttData => isTyping //
      .map((it) => it ? '1' : '0');

  // because sync didn't have this event
  get syncTopic => none();

  mqttMapper(payload) async* {
    yield UserTyping(
      userId: '',
      roomId: 123,
      isTyping: false,
    );
  }

  syncMapper(json) async* {
    yield* Stream.empty();
  }
}

class MessageReceivedEvent with IRealtimeEvent<Message> {
  MessageReceivedEvent({
    @required this.userToken,
  });
  final String userToken;

  get mqttTopic => some('$userToken/c');

  // It is only receiving event, without sending data.
  get mqttData => none();

  get syncTopic => none();

  mqttMapper(payload) async* {
    yield Message();
  }

  syncMapper(json) async* {
    yield Message();
  }
}

void main() async {
  final service = RealtimeService();

  var event = UserTypingEvent(
    roomId: 123,
    userId: 'something',
  );

  service.publish(event);
}

abstract class IRealtimeService {
  MqttClient get mqttClient;
  Dio get dio;
  Stream<bool> get isLogin$;
  Stream<int> get interval$;

  Task<void> publish<In>(IRealtimeEvent<In> event);
  Task<Stream<Out>> subscribe<Out>(IRealtimeEvent<Out> event);
}

class RealtimeService implements IRealtimeService {
  MqttClient mqttClient;
  Dio dio;
  Stream<bool> isLogin$;
  Stream<int> interval$;

  Task<void> publish<In>(IRealtimeEvent<In> event) {
    return mqttClient.publish$(event);
  }

  // it should handle both from mqtt and from sync adapter
  Task<Stream<Out>> subscribe<Out>(IRealtimeEvent<Out> event) {
    return mqttClient.subscribe$<Out>(event);
  }
}

extension on MqttClient {
  Task<Stream<Out>> subscribe$<Out>(IRealtimeEvent<Out> event) {
    return event.mqttTopic.fold(() {
      return Task(() async => Stream<String>.empty());
    }, (topic) {
      return Task(() async => _listen(topic: topic));
    }).map((stream) {
      final transformer = StreamTransformer<String, Out>.fromHandlers(
        handleData: (data, sink) async {
          await for (var result in event.mqttMapper(data)) {
            sink.add(result);
          }
        },
      );
      return stream.transform(transformer);
    });
  }

  Stream<String> _listen({@required String topic}) async* {
    if (updates == null) {
      yield* Stream.empty();
    } else {
      yield* MqttClientTopicFilter(topic, updates)
          .updates
          .transform<String>(StreamTransformer.fromHandlers(
            handleData: (data, sink) => data
                .map((message) => message.payloadMessageString)
                .forEach((payload) => sink.add(payload)),
          ));
    }
  }

  Task<void> publish$(IRealtimeEvent event) {
    return Task.delay(() {
      return event.mqttTopic.bind(
        (topic) => event.mqttData.map((data) => tuple2(topic, data)),
      );
    }).map((data) {
      return data.fold(() {
        return Task.delay(() {});
      }, (data) {
        _publish$(
          topic: data.value1,
          payload: data.value2,
        );
      });
    });
  }

  void _publish$({
    @required String topic,
    @required String payload,
  }) {
    var data = MqttClientPayloadBuilder()..addString(payload);
    this.publishMessage(topic, MqttQos.atLeastOnce, data.payload);
  }
}

extension on MqttReceivedMessage<MqttMessage> {
  String get payloadMessageString => MqttPublishPayload //
      .bytesToStringAsString((this as MqttPublishMessage).payload.message);
}
