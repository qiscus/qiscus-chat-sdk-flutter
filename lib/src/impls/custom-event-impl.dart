import 'dart:async';
import 'dart:convert';

import 'package:qiscus_chat_sdk/src/domain/custom-event/custom-event-model.dart';
import 'package:qiscus_chat_sdk/src/impls/mqtt-impls.dart';

import '../core.dart';

final StreamTransformer<QMqttMessage, QCustomEvent>
    mqttCustomEventTransformerImpl =
    StreamTransformer.fromHandlers(handleData: (data, sink) {
  var roomId = int.parse(data.topic.split('/')[1]);
  var payload = jsonDecode(data.payload) as Json;

  sink.add(QCustomEvent(roomId: roomId, payload: payload));
});
