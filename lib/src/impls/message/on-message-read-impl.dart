import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:mqtt_client/mqtt_client.dart' hide MessageReceived;
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/message/message-model.dart';
import 'package:qiscus_chat_sdk/src/impls/message/message-receipt-impl.dart';
import 'package:qiscus_chat_sdk/src/impls/mqtt-impls.dart';
import 'package:qiscus_chat_sdk/src/impls/sync.dart';

// Lihat catatan di on-message-delivered-impl.dart.

Reader<MqttClient, IO<Stream<MessageReceipt>>> onMessageReadImpl(int roomId) {
  return mqttForTopic(TopicBuilder.messageRead(roomId.toString())).map((io) =>
      io.map((stream) => stream.transform(mqttMessageReadTransformerImpl)));
}

var mqttMessageReadTransformerImpl =
    StreamTransformer<QMqttMessage, MessageReceipt>.fromBind((stream) {
  return stream
      .where((it) => reRead.hasMatch(it.topic))
      .map((it) => MessageReceipt.fromMqtt(it.topic, it.payload))
      .where((it) => it != null)
      .map((it) => it!);
});

var syncMessageReadTransformerImpl =
    StreamTransformer<QRealtimeEvent, MessageReceipt>.fromBind((stream) {
  return stream
      .map(MessageReceipt.fromRealtimeEvent)
      .where((it) => it?.status == QMessageStatus.read)
      .map((it) => it!);
});
