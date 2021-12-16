part of qiscus_chat_sdk.core;

class Storage {
  Storage();

  static const defaultBaseUrl = 'https://api.qiscus.com';
  static const defaultUploadUrl = '$defaultBaseUrl/api/v2/sdk/upload';
  static const defaultBrokerUrl = 'realtime-jogja.qiscus.com';
  static const defaultBrokerLbUrl = 'https://realtime-lb.qiscus.com';
  static const defaultAccInterval = 1000;
  static const defaultSyncInterval = 5000;
  static const defaultSyncIntervalWhenConnected = 30000;

  String appId;
  String version;
  String token;
  Account currentUser;
  Map<String, String> customHeaders;

  var baseUrl = defaultBaseUrl;
  var brokerUrl = defaultBrokerUrl;
  var brokerLbUrl = defaultBrokerLbUrl;
  var uploadUrl = defaultUploadUrl;
  var syncInterval = defaultSyncInterval.milliseconds;
  var syncIntervalWhenConnected = defaultSyncIntervalWhenConnected.milliseconds;

  /// accumulator interval, interval for periodically running sync http
  /// request
  var accSyncInterval = defaultAccInterval.milliseconds;
  var debugEnabled = false;
  var brokerLbEnabled = true;
  String get userId => currentUser?.id;
  var lastMessageId = 0;
  var lastEventId = 0;
  var enableEventReport = false;
  var isRealtimeEnabled = true;
  var isRealtimeCheckEnabled = true;
  var configExtras = <String, dynamic>{};
  var logLevel = QLogLevel.debug;

  void clear() {
    appId = null;
    currentUser = null;
    token = null;
  }
}

extension StorageX on Storage {
  Future<bool> get authenticated$ =>
      Stream<bool>.periodic(const Duration(milliseconds: 130))
          .map((_) => currentUser != null)
          .distinct()
          .firstWhere((it) => it == true);

  AppConfig get appConfig => AppConfig(
        baseUrl: Option.some(baseUrl),
        brokerLbUrl: Option.some(brokerLbUrl),
        brokerUrl: Option.some(brokerUrl),
        enableEventReport: Option.none(),
        enableRealtime: Option.some(isRealtimeEnabled),
        enableRealtimeCheck: Option.some(isRealtimeCheckEnabled),
        extras: Option.some(configExtras),
        syncInterval: Option.some(syncInterval.inMilliseconds),
        syncOnConnect: Option.some(syncIntervalWhenConnected.inMilliseconds),
      );
}
