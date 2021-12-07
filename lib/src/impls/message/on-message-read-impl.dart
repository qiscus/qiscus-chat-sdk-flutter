import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:mqtt_client/mqtt_client.dart' hide MessageReceived;
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/message/message-model.dart';
import 'package:qiscus_chat_sdk/src/impls/mqtt-impls.dart';
import 'package:qiscus_chat_sdk/src/impls/sync.dart';

Reader<MqttClient, IO<Stream<State<Iterable<QMessage>, QMessage?>>>>
    onMessageReadImpl(int roomId) {
  return mqttForTopic(TopicBuilder.messageRead(roomId.toString())).map((io) =>
      io.map((stream) => stream
          .map((it) => it.payload)
          .transform(_mqttMessageReadTransformer)
          .transform(_mqttEventReceived)));
}

StreamTransformer<QMessageReadEvent, State<Iterable<QMessage>, QMessage?>>
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
          it.status = QMessageStatus.read;
          return it;
        }).toNullable();
        return Tuple2(message, messages);
      });
    }
  },
);

var messageReadTransformerImpl = StreamTransformer<QMqttMessage,
    State<Iterable<QMessage>, QMessage?>>.fromBind((stream) {
  return stream
      .where((it) => reRead.hasMatch(it.topic))
      .map((it) => it.payload)
      .transform(_mqttMessageReadTransformer)
      .transform(_mqttEventReceived);
});

var _syncEventReceived =
    StreamTransformer<QRealtimeEvent, QMessageReadEvent>.fromBind(
  (stream) async* {
    await for (var event in stream) {
      yield* event.fold(
        messageDeleted: (_) => Stream.empty(),
        messageDelivered: (_) => Stream.empty(),
        roomCleared: (_) => Stream.empty(),
        unknown: (_) => Stream.empty(),
        messageRead: (e) =>
            Stream.value(QMessageReadEvent(e.messageId, e.messageUniqueId)),
      );
    }
  },
);
var syncMessageReadTransformerImpl = StreamTransformer<QRealtimeEvent,
    State<Iterable<QMessage>, QMessage?>>.fromBind((stream) {
  return stream //
      .transform(_syncEventReceived)
      .transform(_mqttEventReceived);
});


final _mqttMessageReadTransformer =
StreamTransformer<String, QMessageReadEvent>.fromBind(
      (stream) async* {
    await for (var item in stream) {
      var payload = item.split(':');
      var commentId = int.parse(payload[0]);
      var commentUniqueId = payload[1];

      yield QMessageReadEvent(commentId, commentUniqueId);
    }
  },
);

class QMessageReadEvent {
  const QMessageReadEvent(this.messageId, this.messageUniqueId);

  final int? messageId;
  final String messageUniqueId;
}
