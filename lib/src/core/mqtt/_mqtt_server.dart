import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../core.dart';
import '_mqtt_stub.dart';

MqttClient getMqttClient(Storage storage) {
  final clientId = getClientId();
  final connectionMessage = getConnectionMessage(clientId, storage?.userId);
  final brokerUrl = storage.brokerUrl;

  return MqttServerClient(brokerUrl, clientId)
        ..logging(on: false)
        ..port = 1886
        ..connectionMessage = connectionMessage
        ..websocketProtocols = ['mqtt']
      //
      ;
}
