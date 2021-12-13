
import 'dart:async';

import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/user/user-model.dart';
import 'package:qiscus_chat_sdk/src/impls/mqtt-impls.dart';

final StreamTransformer<QMqttMessage, QUserPresence>
mqttUserPresenceTransformerImpl =
StreamTransformer.fromHandlers(handleData: (data, sink) {
  if (reOnlineStatus.hasMatch(data.topic)) {
    var payload = data.payload.split(':');
    var userId_ = data.topic.split('/')[1];
    var onlineStatus = payload[0] == '1' ? true : false;
    var timestamp = DateTime.fromMillisecondsSinceEpoch(int.parse(payload[1]));
    sink.add(QUserPresence(
      userId: userId_,
      isOnline: onlineStatus,
      lastSeen: timestamp,
    ));
  }
});
