import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:mqtt_client/mqtt_client.dart' hide MessageReceived;
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/message/message-model.dart';
import 'package:qiscus_chat_sdk/src/impls/mqtt-impls.dart';
import 'package:qiscus_chat_sdk/src/impls/sync.dart';


Reader<MqttClient, IO<Stream<State<Iterable<QMessage>, QMessage?>>>>
    onMessageDeliveredImpl(int roomId) {
  return mqttForTopic(
    TopicBuilder.messageDelivered(roomId.toString()),
  ).map((io) {
    return io.map((stream) {
      return stream
        .map((it) => it.payload)
        .transform(_mqttMessageDeliveredTransformerImpl)
        .transform(_mqttEventReceived);
    });
  });
}

StreamTransformer<QMessageDeliveredEvent, State<Iterable<QMessage>, QMessage?>>
    _mqttEventReceived = StreamTransformer.fromBind(
  (stream) async* {
    await for (var data in stream) {
      yield State((Iterable<QMessage> messages) {
        var message = messages //
            .where((item) =>
                item.uniqueId == data.messageUniqueId ||
                item.id == data.messageId)
            .head
            .map((it) {
          it.status = QMessageStatus.delivered;
          return it;
        }).toNullable();
        return Tuple2(message, messages);
      });
    }
  },
);

var messageDeliveredTransformerImpl = StreamTransformer<QMqttMessage,
    State<Iterable<QMessage>, QMessage?>>.fromBind((stream) {
  return stream
      .where((it) => reRead.hasMatch(it.topic))
      .map((it) => it.payload)
      .transform(_mqttMessageDeliveredTransformerImpl)
      .transform(_mqttEventReceived);
});

var _syncEventReceived =
    StreamTransformer<QRealtimeEvent, QMessageDeliveredEvent>.fromBind(
  (stream) async* {
    await for (var event in stream) {
      yield* event.fold(
        messageDeleted: (_) => Stream.empty(),
        messageDelivered: (e) => Stream.value(
            QMessageDeliveredEvent(e.messageId, e.messageUniqueId)),
        roomCleared: (_) => Stream.empty(),
        unknown: (_) => Stream.empty(),
        messageRead: (_) => Stream.empty(),
      );
    }
  },
);
var syncMessageDeliveredTransformerImpl = StreamTransformer<QRealtimeEvent,
    State<Iterable<QMessage>, QMessage?>>.fromBind((stream) {
  return stream //
      .transform(_syncEventReceived)
      .transform(_mqttEventReceived);
});


final _mqttMessageDeliveredTransformerImpl =
StreamTransformer<String, QMessageDeliveredEvent>.fromBind(
      (stream) async* {
    await for (var item in stream) {
      var payload = item.split(':');
      var commentId = int.parse(payload[0]);
      var commentUniqueId = payload[1];

      yield QMessageDeliveredEvent(commentId, commentUniqueId);
    }
  },
);

class QMessageDeliveredEvent {
  const QMessageDeliveredEvent(this.messageId, this.messageUniqueId);

  final int? messageId;
  final String messageUniqueId;
}
