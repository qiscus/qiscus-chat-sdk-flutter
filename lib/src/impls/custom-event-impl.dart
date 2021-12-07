import 'dart:async';
import 'dart:convert';

import 'package:qiscus_chat_sdk/src/domain/custom-event/custom-event-model.dart';
import 'package:qiscus_chat_sdk/src/impls/mqtt-impls.dart';

final StreamTransformer<QMqttMessage, QCustomEvent>
mqttCustomEventTransformerImpl = StreamTransformer.fromBind((stream) async* {
  await for (var data in stream) {
    var roomId = int.parse(data.topic.split('/')[1]);
    var payload = jsonDecode(data.payload) as Map<String, dynamic>;

    yield QCustomEvent(roomId: roomId, payload: payload);
  }
});