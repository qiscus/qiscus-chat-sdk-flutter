import 'dart:async';
import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:mqtt_client/mqtt_client.dart' hide MessageReceived;
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/message/message-model.dart';
import 'package:qiscus_chat_sdk/src/impls/mqtt-impls.dart';
import 'package:qiscus_chat_sdk/src/impls/sync.dart';


final mqttMessageDeletedTransformerImpl = StreamTransformer<QMqttMessage,
        State<Iterable<QMessage>, QMessage?>>.fromBind(
    (Stream<QMqttMessage> stream) => stream
        .transform(_mqttMessageDeletedTransformerImpl)
        .transform(_eventReceiveProcess));

StreamTransformer<QMessageDeletedEvent, State<Iterable<QMessage>, QMessage?>>
    _eventReceiveProcess = StreamTransformer.fromBind(
  (stream) async* {
    await for (var data in stream) {
      yield State((Iterable<QMessage> messages) {
        var message =
            messages.firstWhere((it) => it.uniqueId == data.messageUniqueId);
        var _messages =
            messages.where((it) => it.uniqueId != data.messageUniqueId);
        return Tuple2(message, _messages);
      });
    }
  },
);

var _syncEventReceived =
    StreamTransformer<QRealtimeEvent, QMessageDeletedEvent>.fromBind(
  (stream) async* {
    await for (var event in stream) {
      yield* event.fold(
        messageDeleted: (_) => Stream.empty(),
        messageDelivered: (e) =>
            Stream.value(QMessageDeletedEvent(e.messageId, e.messageUniqueId)),
        roomCleared: (_) => Stream.empty(),
        unknown: (_) => Stream.empty(),
        messageRead: (_) => Stream.empty(),
      );
    }
  },
);
var syncMessageDeletedTransformerImpl = StreamTransformer<QRealtimeEvent,
    State<Iterable<QMessage>, QMessage?>>.fromBind((stream) {
  return stream //
      .transform(_syncEventReceived)
      .transform(_eventReceiveProcess);
});

final _mqttMessageDeletedTransformerImpl =
    StreamTransformer<QMqttMessage, QMessageDeletedEvent>.fromBind(
  (stream) async* {
    await for (var data in stream) {
      var json = jsonDecode(data.payload) as Map<String, dynamic>;
      var actionType = json['action_topic'] as String;
      var payload = json['payload'] as Map<String, dynamic>;

      if (actionType == 'delete_message') {
        var mPayload = (payload['data']['deleted_messages'] as List)
            .cast<Map<String, dynamic>>();
        for (var m in mPayload) {
          var roomId = int.parse(m['room_id'] as String);
          var uniqueIds = (m['message_unique_ids'] as List).cast<String>();
          for (var uniqueId in uniqueIds) {
            yield QMessageDeletedEvent(roomId, uniqueId);
          }
        }
      }
    }
  },
);

class QMessageDeletedEvent {
  const QMessageDeletedEvent(this.roomId, this.messageUniqueId);

  final int? roomId;
  final String messageUniqueId;
}
