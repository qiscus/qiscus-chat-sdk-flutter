part of qiscus_chat_sdk.core;

MqttClient getMqttClient(Storage storage) {
  // final errorMessage = 'You are currently not signed in on qiscus sdk.'
  //     ' If you get this error after hot reload, please hot restart the application'
  //     ' instead. That will re-initialize internal variable inside qiscus sdk.';
  // if (storage.userId == null) throw Exception(errorMessage);

  final clientId = getClientId(appId: storage.appId, userId: storage.userId);
  final connectionMessage =
      getConnectionMessage(clientId, storage.userId ?? 'unknown');
  final brokerUrl = storage.brokerUrl;

  return MqttServerClient(brokerUrl, clientId)
        ..logging(on: false)
        ..port = 1885
        ..connectionMessage = connectionMessage
        ..websocketProtocols = ['mqtt']
        ..secure = true
        ..autoReconnect = true
      //
      ;
}

String getClientId({String? appId, String? userId, int? millis}) {
  var clientId = 'flutter';
  var _millis = millis ?? DateTime.now().millisecondsSinceEpoch;

  if (appId != null) {
    clientId += '_$appId';
  }
  if (userId != null) {
    clientId += '_$userId';
  }

  return '${clientId}_$_millis';
}

MqttConnectMessage getConnectionMessage(String clientId, String userId) {
  return MqttConnectMessage()
        ..withClientIdentifier(clientId)
        ..withWillTopic('u/$userId/s')
        ..withWillMessage('0')
        ..withWillRetain()
      //
      ;
}

abstract class MqttEventHandler<OutData> {
  const MqttEventHandler();
  String get topic;
  String publish();
  Stream<OutData> receive(Tuple2<String, String> message);
}
