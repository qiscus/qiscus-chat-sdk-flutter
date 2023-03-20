import 'dart:async';
import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/message/message-model.dart';
import 'package:qiscus_chat_sdk/src/impls/message/message-from-json-impl.dart';
import 'package:qiscus_chat_sdk/src/impls/mqtt-impls.dart';

final StreamTransformer<QMqttMessage, State<Iterable<QMessage>, QMessage>>
    mqttMessageUpdatedTransformerImpl =
    StreamTransformer.fromHandlers(handleData: (data, sink) {
  if (reMessageUpdated.hasMatch(data.topic)) {
    var json = jsonDecode(data.payload) as Json;
    var message = messageFromJson(json);

    sink.add(State((messages) {
      return Tuple2(message, messages);
    }));
  }
});
