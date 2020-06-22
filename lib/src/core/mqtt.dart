import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';

MqttClient getMqttClient(Storage storage) {
  final clientId = () => 'dart-sdk-${DateTime.now().millisecondsSinceEpoch}';

  var clientId_ = clientId();
  final connectionMessage = MqttConnectMessage() //
          .withClientIdentifier(clientId_)
          .withWillTopic('u/${storage.currentUser?.id}/s')
          .withWillMessage('0')
          .withWillRetain()
      //
      ;

  var brokerUrl = storage.brokerUrl;
  var client = MqttServerClient(brokerUrl, clientId_)
        ..logging(on: false)
        ..useWebSocket = true
        ..port = 1886
        ..connectionMessage = connectionMessage
        ..websocketProtocols = ['mqtt']
      //
      ;

  return client;
}

abstract class MqttEventHandler<InData, OutData> {
  const MqttEventHandler();

  String get topic;

  String publish();

  Stream<OutData> receive(CMqttMessage message);
}
