import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:mqtt_client/mqtt_client.dart' hide MessageReceived;
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/message/message-model.dart';
import 'package:qiscus_chat_sdk/src/impls/message/message-receipt-impl.dart';
import 'package:qiscus_chat_sdk/src/impls/mqtt-impls.dart';
import 'package:qiscus_chat_sdk/src/impls/sync.dart';

// Di sini receipt hanya diubah jadi [MessageReceipt]. Penerapannya ke store,
// termasuk cascade ke pesan sebelumnya di room yang sama, ada di
// `applyMessageReceipt` karena butuh id user yang sedang login.

Reader<MqttClient, IO<Stream<MessageReceipt>>> onMessageDeliveredImpl(
    int roomId) {
  return mqttForTopic(
    TopicBuilder.messageDelivered(roomId.toString()),
  ).map((io) {
    return io.map((stream) {
      return stream.transform(mqttMessageDeliveredTransformerImpl);
    });
  });
}

var mqttMessageDeliveredTransformerImpl =
    StreamTransformer<QMqttMessage, MessageReceipt>.fromBind((stream) {
  return stream
      .where((it) => reDelivery.hasMatch(it.topic))
      .map((it) => MessageReceipt.fromMqtt(it.topic, it.payload))
      .where((it) => it != null)
      .map((it) => it!);
});

var syncMessageDeliveredTransformerImpl =
    StreamTransformer<QRealtimeEvent, MessageReceipt>.fromBind((stream) {
  return stream
      .map(MessageReceipt.fromRealtimeEvent)
      .where((it) => it?.status == QMessageStatus.delivered)
      .map((it) => it!);
});
