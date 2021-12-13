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
    _mqttEventReceived = StreamTransformer.fromHandlers(
  handleData: (data, sink) {
    sink.add(State((Iterable<QMessage> messages) {
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
    }));
  },
);

var mqttMessageReadTransformerImpl = StreamTransformer<QMqttMessage,
    State<Iterable<QMessage>, QMessage?>>.fromBind((stream) {
  return stream
      .where((it) => reRead.hasMatch(it.topic))
      .map((it) => it.payload)
      .transform(_mqttMessageReadTransformer)
      .transform(_mqttEventReceived);
});

var _syncEventReceived =
    StreamTransformer<QRealtimeEvent, QMessageReadEvent>.fromHandlers(
  handleData: (event, sink) {
    event.flow(
      messageDeleted: (_) {},
      messageDelivered: (_) {},
      roomCleared: (_) {},
      unknown: (_) {},
      messageRead: (e) =>
          sink.add(QMessageReadEvent(e.messageId, e.messageUniqueId)),
    );
  },
);
var syncMessageReadTransformerImpl = StreamTransformer<QRealtimeEvent,
    State<Iterable<QMessage>, QMessage?>>.fromBind((stream) {
  return stream //
      .transform(_syncEventReceived)
      .transform(_mqttEventReceived);
});

final _mqttMessageReadTransformer =
    StreamTransformer<String, QMessageReadEvent>.fromHandlers(
  handleData: (data, sink) {
    var payload = data.split(':');
    var commentId = int.parse(payload[0]);
    var commentUniqueId = payload[1];

    sink.add(QMessageReadEvent(commentId, commentUniqueId));
  },
);

class QMessageReadEvent {
  const QMessageReadEvent(this.messageId, this.messageUniqueId);

  final int? messageId;
  final String messageUniqueId;
}
