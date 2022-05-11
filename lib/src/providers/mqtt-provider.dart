import 'dart:async';
import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:qiscus_chat_sdk/src/impls/mqtt-impls.dart';
import 'package:qiscus_chat_sdk/src/providers/commons.dart';
import 'package:qiscus_chat_sdk/src/providers/states.dart';
import 'package:riverpod/riverpod.dart';

final clientIdProvider = FutureProvider<String>((ref) {
  var account = ref.watch(accountProvider);
  var now = DateTime.now().millisecond;

  if (account == null) {
    return 'mqtt-flutter-$now';
  } else {
    return 'mqtt-flutter-${account.id}-$now';
  }
});

final mqttClientProvider = FutureProvider<MqttClient>((ref) async {
  var brokerUrl = ref.watch(brokerUrlProvider);
  var clientId = await ref.watch(clientIdProvider.future);

  var client = MqttClient(brokerUrl, clientId);

  client.autoReconnect = true;
  return client;
});

final mqttSubscribeProvider =
    FutureProvider.family<void, String>((ref, String topic) async {
  var mqtt = await ref.watch(mqttClientProvider.future);
  mqtt.subscribe(topic, MqttQos.atLeastOnce);
});
final mqttUnsubscribeProvider =
    FutureProvider.family<void, String>((ref, String topic) async {
  var mqtt = await ref.watch(mqttClientProvider.future);
  mqtt.unsubscribe(topic);
});

typedef RawMqttMessage = List<MqttReceivedMessage<MqttMessage>>;
final mqttUpdatesProvider =
    StreamProvider.autoDispose<RawMqttMessage>((ref) async* {
  var mqtt = await ref.watch(mqttClientProvider.future);
  if (mqtt.updates != null) {
    yield* mqtt.updates!;
  } else {
    yield* Stream.empty();
  }
});

StreamTransformer<MqttUpdatesData, QMqttMessage> _mqttExpandTransformer =
    StreamTransformer.fromHandlers(handleData: (source, sink) {
  for (var data in source) {
    var payload = data.payload as MqttPublishMessage;
    var message = utf8.decode(payload.payload.message);
    var topic = data.topic;

    sink.add(QMqttMessage(topic, message));
  }
});
