import 'dart:async';
import 'dart:convert';

import 'package:qiscus_chat_sdk/src/domain/custom-event/custom-event-model.dart';
import 'package:qiscus_chat_sdk/src/impls/mqtt-impls.dart';

final StreamTransformer<QMqttMessage, QCustomEvent>
mqttCustomEventTransformerImpl = StreamTransformer.fromHandlers(handleData: (data, sink) {
  var roomId = int.parse(data.topic.split('/')[1]);
  var payload = jsonDecode(data.payload) as Map<String, dynamic>;

  sink.add(QCustomEvent(roomId: roomId, payload: payload));
});
