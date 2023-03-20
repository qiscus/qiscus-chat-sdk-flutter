import 'dart:async';
import 'dart:convert';

import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/impls/mqtt-impls.dart';
import 'package:qiscus_chat_sdk/src/impls/sync.dart';

StreamTransformer<QMqttMessage, int> mqttRoomClearedTransformerImpl =
    StreamTransformer.fromHandlers(handleData: (data, sink) {
  if (reNotification.hasMatch(data.topic)) {
    var json = jsonDecode(data.payload) as Json;
    var actionType = json['action_topic'] as String;
    var payload = json['payload'] as Json;

    if (actionType == 'clear_room') {
      var rooms =
          ((payload['data'] as Map)['deleted_rooms'] as List).cast<Json>();
      var roomIds = rooms.map((room) => room['id'] as int);

      for (var roomId in roomIds) {
        sink.add(roomId);
      }
    }
  }
});

StreamTransformer<QRealtimeEvent, int> syncRoomClearedTransformerImpl =
    StreamTransformer.fromHandlers(handleData: (data, sink) {
  data.flow(
    messageDeleted: (_) {},
    messageDelivered: (_) {},
    messageRead: (_) {},
    roomCleared: (e) => sink.add(e.roomId),
    unknown: (_) {},
  );
});
