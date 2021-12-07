
import 'dart:async';

import 'package:qiscus_chat_sdk/src/domain/user/user-model.dart';
import 'package:qiscus_chat_sdk/src/impls/mqtt-impls.dart';

final StreamTransformer<QMqttMessage, QUserPresence>
mqttUserPresenceTransformerImpl =
StreamTransformer.fromBind((stream) async* {
  await for (var data in stream) {
    var payload = data.payload.split(':');
    var userId_ = data.topic.split('/')[1];
    var onlineStatus = payload[0] == '1' ? true : false;
    var timestamp = DateTime.fromMillisecondsSinceEpoch(int.parse(payload[1]));
    yield QUserPresence(
      userId: userId_,
      isOnline: onlineStatus,
      lastSeen: timestamp,
    );
  }
});
