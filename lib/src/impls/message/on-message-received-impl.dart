import 'dart:async';
import 'dart:convert';

import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/message/message-model.dart';
import 'package:qiscus_chat_sdk/src/impls/mqtt-impls.dart';

import 'message-from-json-impl.dart';

StreamTransformer<QMqttMessage, QMessage> mqttMessageReceivedTransformer =
    StreamTransformer.fromHandlers(handleData: (data, sink) {
  if (reNewMessage.hasMatch(data.topic)) {
    var json = jsonDecode(data.payload) as Json;
    var message = messageFromJson(json);

    sink.add(message);
  }
});
