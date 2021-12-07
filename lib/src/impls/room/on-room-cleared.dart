
import 'dart:async';
import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/domain/room/room-model.dart';
import 'package:qiscus_chat_sdk/src/impls/mqtt-impls.dart';
import 'package:qiscus_chat_sdk/src/impls/sync.dart';

StreamTransformer<QMqttMessage, int>
mqttRoomClearedTransformerImpl = StreamTransformer.fromBind((stream) async* {
  await for (var data in stream) {
    var json = jsonDecode(data.payload) as Map<String, dynamic>;
    var actionType = json['action_topic'] as String;
    var payload = json['payload'] as Map<String, dynamic>;

    if (actionType == 'clear_room') {
      var rooms = (payload['data']['deleted_rooms'] as List)
          .cast<Map<String, dynamic>>();
      var roomIds = rooms.map((room) => room['id'] as int);

      for (var roomId in roomIds) {
        yield roomId;
      }
    }
  }
});

StreamTransformer<QRealtimeEvent, int>
syncRoomClearedTransformerImpl = StreamTransformer.fromBind((stream) async* {
  await for (var data in stream) {
    yield* data.fold(
      messageDeleted: (_) => Stream.empty(),
      messageDelivered: (_) => Stream.empty(),
      messageRead: (_) => Stream.empty(),
      roomCleared: (e) => Stream.value(e.roomId),
      unknown: (_) => Stream.empty(),
    );
  }
});