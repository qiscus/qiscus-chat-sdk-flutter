import 'package:mqtt_client/mqtt_client.dart';

import '../../../qiscus_chat_sdk.dart';
import '../core.dart';

export 'package:mqtt_client/mqtt_client.dart' show MqttClient;

MqttClient getMqttClient(Storage storage) {
  throw QError('Unsupported platform');
}

String getClientId() {
  return 'dart-sdk-${DateTime.now().millisecondsSinceEpoch}';
}

MqttConnectMessage getConnectionMessage(String clientId, String userId) {
  return MqttConnectMessage()
        ..withClientIdentifier(clientId)
        ..withWillTopic(userId)
        ..withWillMessage('0')
        ..withWillRetain()
      //
      ;
}
