import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';

MqttClient getMqttClient(Storage storage) {
  final clientId = () => 'dart-sdk-${DateTime.now().millisecondsSinceEpoch}';

  final connectionMessage = MqttConnectMessage() //
          .withClientIdentifier(clientId())
          .withWillTopic('u/${storage.currentUser?.id}/s')
          .withWillMessage('0')
          .withWillRetain()
      //
      ;

  var brokerUrl = 'wss://mqtt.qiscus.com/mqtt';
  var client = MqttServerClient(brokerUrl, 'sdk-dart')
        ..logging(on: false)
        ..useWebSocket = true
        ..port = 1886
        ..connectionMessage = connectionMessage
        ..websocketProtocols = ['mqtt']
      //
      ;
  return client;
}
