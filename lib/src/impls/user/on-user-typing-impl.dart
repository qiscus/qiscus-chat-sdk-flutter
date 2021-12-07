
import 'dart:async';

import 'package:qiscus_chat_sdk/src/domain/user/user-model.dart';
import 'package:qiscus_chat_sdk/src/impls/mqtt-impls.dart';

final StreamTransformer<QMqttMessage, QUserTyping>
mqttUserTypingTransformerImpl = StreamTransformer.fromBind((stream) async* {
  await for (var data in stream) {
    var topic = data.topic.split('/');
    var roomId = int.parse(topic[1]);
    var userId = topic[3];
    yield QUserTyping(
      isTyping: data.payload == '1',
      roomId: roomId,
      userId: userId,
    );
  }
});
