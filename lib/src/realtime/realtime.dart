library qiscus_chat_sdk.realtime;

import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:qiscus_chat_sdk/src/features/custom_event/custom_event.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/realtime.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';

import '../features/message/message.dart';
import '../type_utils.dart';

part 'custom_event.dart';

part 'message_deleted.dart';

part 'message_delivered.dart';

part 'message_read.dart';

part 'message_received.dart';

part 'message_updated.dart';

part 'notification.dart';

part 'room_cleared.dart';

part 'user_presence.dart';

part 'user_typing.dart';

abstract class IMqttReceive<O> {
  const IMqttReceive();

  String get topic;

  Stream<O> receive(Tuple2<String, String> data);
}

abstract class IMqttPublish<I> {
  const IMqttPublish();

  String get topic;

  String publish();
}

extension IMqttReceiveX on MqttClient {
  Stream<Tuple2<String, String>> forTopic(String topic) async* {
    if (updates == null) {
      yield* Stream.empty();
    } else {
      yield* MqttClientTopicFilter(topic, updates)
          .updates
          ?.expand((events) => events)
          ?.asyncMap((event) {
        var p = event.payload as MqttPublishMessage;
        var m = p.payload.message;
        var payload = utf8.decode(m);

        return Tuple2(event.topic, payload);
      });
    }
  }

  Stream<O> onEvent<O>(IMqttReceive<O> handler) async* {
    await for (var data in forTopic(handler.topic)) {
      yield* handler.receive(data);
    }
  }

  Future<void> sendEvent<I>(IMqttPublish<I> handler) async {
    var payload = MqttClientPayloadBuilder()..addString(handler.publish());
    publishMessage(handler.topic, MqttQos.atLeastOnce, payload.payload);
  }

  bool get isConnected {
    return connectionStatus.state == MqttConnectionState.connected;
  }

  void subscribe$(String topic) {
    subscribe(topic, MqttQos.atLeastOnce);
  }
}
