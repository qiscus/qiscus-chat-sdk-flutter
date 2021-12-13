
import 'dart:async';

import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/user/user-model.dart';
import 'package:qiscus_chat_sdk/src/impls/mqtt-impls.dart';

final StreamTransformer<QMqttMessage, QUserTyping>
mqttUserTypingTransformerImpl = StreamTransformer.fromHandlers(handleData: (data, sink) {
  if (reTyping.hasMatch(data.topic)) {
    var topic = data.topic.split('/');
    var roomId = int.parse(topic[1]);
    var userId = topic[3];
    sink.add(QUserTyping(
      isTyping: data.payload == '1',
      roomId: roomId,
      userId: userId,
    ));
  }
});
