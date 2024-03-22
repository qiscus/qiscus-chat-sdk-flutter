import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/impls/mqtt-impls.dart';

ReaderTaskEither<MqttClient, QError, Unit> publishCustomEventImpl(
    int roomId, Json payload) {
  return Reader((mqtt) {
    return tryCatch(() async {
      mqttSendEvent(TopicBuilder.customEvent(roomId), jsonEncode(payload));

      return unit;
    });
  });
}
