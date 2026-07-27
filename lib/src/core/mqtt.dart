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
        // Tanpa keep alive, `mqtt_client` tidak pernah mengirim PINGREQ
        // ("Keep alive is defaulted to off" - dokumentasi MqttClient.keepAlivePeriod).
        // Akibatnya client tidak bisa mendeteksi broker yang berhenti merespons
        // selama socket TCP-nya masih ESTABLISHED (zombie connection).
        ..keepAlivePeriod = defaultKeepAlivePeriod
        // Keep alive saja tidak cukup: tanpa ini, PINGREQ yang tidak dibalas
        // dibiarkan menggantung selamanya. Dengan ini client memutus paksa
        // dirinya sendiri lalu auto reconnect berjalan.
        ..disconnectOnNoResponsePeriod = defaultNoPingResponsePeriod
        // Default-nya memang true sejak v8.0.0, di-set eksplisit supaya
        // perilaku re-subscribe tidak berubah diam-diam saat upgrade.
        ..resubscribeOnAutoReconnect = true
      //
      ;
}

/// Interval PINGREQ ke broker, dalam detik.
const defaultKeepAlivePeriod = 60;

/// Batas tunggu PINGRESP sebelum client memutus dirinya sendiri, dalam detik.
const defaultNoPingResponsePeriod = 30;

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
      // Keep alive TIDAK perlu di-set di sini. `MqttClient.connect()` selalu
      // menimpa `connectMessage.variableHeader.keepAlive` dengan
      // `client.keepAlivePeriod`, bahkan untuk connection message yang kita
      // pasang sendiri (mqtt_client 9.8.1, mqtt_client.dart:320). Cukup set
      // `keepAlivePeriod` di `getMqttClient()`.
      ;
}

abstract class MqttEventHandler<OutData> {
  const MqttEventHandler();
  String get topic;
  String publish();
  Stream<OutData> receive(Tuple2<String, String> message);
}
