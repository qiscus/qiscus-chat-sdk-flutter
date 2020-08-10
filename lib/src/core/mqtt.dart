import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'core.dart';

MqttClient getMqttClient(Storage storage) {
  MqttClient client;
  String clientId() {
    return 'dart-sdk-${DateTime.now().millisecondsSinceEpoch}';
  }

  var _clientId = clientId();
  final connectionMessage = MqttConnectMessage() //
          .withClientIdentifier(_clientId)
          .withWillTopic('u/${storage.currentUser?.id}/s')
          .withWillMessage('0')
          .withWillRetain()
      //
      ;

  var brokerUrl = storage.brokerUrl;

  client = MqttServerClient(brokerUrl, _clientId)
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
