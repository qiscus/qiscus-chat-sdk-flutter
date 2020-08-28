part of qiscus_chat_sdk.core;

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

abstract class MqttEventHandler<InData, OutData> {
  const MqttEventHandler();
  String get topic;
  String publish();
  Stream<OutData> receive(Tuple2<String, String> message);
}
