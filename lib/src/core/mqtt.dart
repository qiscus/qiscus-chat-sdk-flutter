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
        // Keep alive default-nya mati. Tanpa ini client tidak pernah mengirim
        // ping berkala, sehingga realtime server yang berhenti merespons tidak
        // bisa dibedakan dari yang sehat selama socket TCP-nya masih
        // ESTABLISHED.
        ..keepAlivePeriod = defaultKeepAlivePeriod
        // Keep alive saja tidak cukup: tanpa ini, ping yang tidak dibalas
        // dibiarkan menggantung selamanya. Dengan ini client memutus paksa
        // dirinya sendiri lalu auto reconnect berjalan.
        ..disconnectOnNoResponsePeriod = defaultNoPingResponsePeriod
        // Sudah default, di-set eksplisit supaya perilaku re-subscribe tidak
        // berubah diam-diam saat dependensi di-upgrade.
        ..resubscribeOnAutoReconnect = true
      //
      ;
}

/// Interval ping keep alive ke realtime server, dalam detik.
const defaultKeepAlivePeriod = 60;

/// Batas tunggu balasan ping sebelum client memutus dirinya sendiri, dalam
/// detik.
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
      // Keep alive TIDAK perlu di-set di sini. Saat connect, nilai keep alive
      // pada connection message selalu ditimpa dengan `keepAlivePeriod` milik
      // client - termasuk untuk connection message yang kita pasang sendiri.
      // Cukup set `keepAlivePeriod` pada client-nya saja.
      ;
}

abstract class MqttEventHandler<OutData> {
  const MqttEventHandler();
  String get topic;
  String publish();
  Stream<OutData> receive(Tuple2<String, String> message);
}
