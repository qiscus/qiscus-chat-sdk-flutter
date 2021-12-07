import 'dart:async';
import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/message/message-model.dart';
import 'package:qiscus_chat_sdk/src/impls/mqtt-impls.dart';

import 'add-message-to-storage.dart';
import 'message-from-json-impl.dart';

Reader<String,
        StreamTransformer<QMqttMessage, State<Iterable<QMessage>, QMessage>>>
    onMessageReceivedTransformerImpl = Reader((token) {
  return StreamTransformer.fromBind((Stream<QMqttMessage> stream) async* {
    var topic = TopicBuilder.messageNew(token);
    var source = stream //
        .where((it) => it.topic == topic)
        .map((it) => it.payload);

    yield* mqttMessageReceivedTransformer
        .bind(source)
        .transform(addMessageToStorage);
  });
});

StreamTransformer<String, QMessage> mqttMessageReceivedTransformer =
    StreamTransformer.fromBind(
  (payload$) async* {
    await for (var payload in payload$) {
      var json = jsonDecode(payload) as Map<String, dynamic>;
      var message = messageFromJson(json);
      yield message;
    }
  },
);
