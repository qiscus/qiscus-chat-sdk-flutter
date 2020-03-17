import 'package:qiscus_chat_sdk/src/features/user/entity/account.dart';

final _makeGetter = <T1>(Map s, String name, [T1 valueIfEmpty]) =>
    s[name] as T1 ?? valueIfEmpty;
final _makeSetter = <T2>(Map s, String name, T2 value) =>
    s.update(name, (_) => value, ifAbsent: () => value);

class Storage {
  Storage();
  final _storage = <String, dynamic>{};

  static const defaultBaseUrl = 'https://api.qiscus.com';
  static const defaultUploadUrl = '$defaultBaseUrl/api/v2/sdk/upload';
//  static const defaultBrokerUrl = 'mqtt.qiscus.com';
  static const defaultBrokerPort = 1335;
//  static const defaultBrokerUrl = 'ssl://mqtt.qiscus.com:1885';
  static const defaultBrokerUrl = 'wss://mqtt.qiscus.com:1886/mqtt';
  static const defaultBrokerLbUrl = 'https://realtime.qiscus.com';
  static const defaultAccInterval = 1000;
  static const defaultSyncInterval = 5000;
  static const defaultSyncIntervalWhenConnected = 30000;

  String get appId => _makeGetter<String>(_storage, 'app-id');
  set appId(String appId) => _makeSetter(_storage, 'app-id', appId);
  String get baseUrl => _makeGetter(_storage, 'base-url', defaultBaseUrl);
  set baseUrl(String baseUrl) => _makeSetter(_storage, 'base-url', baseUrl);
  int get brokerPort => defaultBrokerPort;
  String get brokerUrl => _makeGetter(_storage, 'broker-url', defaultBrokerUrl);
  set brokerUrl(String brokerUrl) =>
      _makeSetter(_storage, 'broker-url', brokerUrl);
  String get brokerLbUrl =>
      _makeGetter(_storage, 'broker-lb-url', defaultBrokerLbUrl);
  set brokerLbUrl(String brokerLbUrl) =>
      _makeSetter(_storage, 'broker-lb-url', brokerLbUrl);
  String get uploadUrl => _makeGetter(_storage, 'upload-url', defaultUploadUrl);
  set uploadUrl(String uploadUrl) =>
      _makeSetter(_storage, 'upload-url', uploadUrl);
  int get syncInterval =>
      _makeGetter(_storage, 'sync-interval', defaultSyncInterval);
  set syncInterval(int syncInterval) =>
      _makeSetter(_storage, 'sync-interval', syncInterval);
  int get syncIntervalWhenConnected => _makeGetter(_storage,
      'sync-interval-when-connected', defaultSyncIntervalWhenConnected);
  set syncIntervalWhenConnected(int interval) =>
      _makeSetter(_storage, 'sync-interval-when-connected', interval);
  int get accSyncInterval =>
      _makeGetter(_storage, 'acc-sync-interval', defaultAccInterval);
  set accSyncInterval(int interval) =>
      _makeSetter(_storage, 'acc-sync-interval', interval);
  String get version => _makeGetter<String>(_storage, 'version');
  set version(String version) => _makeSetter(_storage, 'version', version);
  bool get debugEnabled => _makeGetter(_storage, 'is-debug-enabled', false);
  set debugEnabled(bool enabled) =>
      _makeSetter(_storage, 'is-debug-enabled', enabled);
  bool get brokerLbEnabled =>
      _makeGetter(_storage, 'is-broker-lb-enabled', true);
  set brokerLbEnabled(bool enabled) =>
      _makeSetter(_storage, 'is-broker-lb-enabled', enabled);
  String get token => _makeGetter<String>(_storage, 'token');
  set token(String token) => _makeSetter(_storage, 'token', token);
  Account get currentUser => _makeGetter<Account>(_storage, 'current-user');
  set currentUser(Account user) => _makeSetter(_storage, 'current-user', user);
  String get userId => currentUser.id;

  Map<String, String> get customHeaders =>
      _makeGetter<Map<String, String>>(_storage, 'custom-headers');
  set customHeaders(Map<String, String> headers) =>
      _makeSetter(_storage, 'custom-headers', headers);
  int get lastMessageId => _makeGetter(_storage, 'last-message-id', 0);
  set lastMessageId(int id) => _makeSetter(_storage, 'last-message-id', id);
  int get lastEventId => _makeGetter(_storage, 'last-event-id', 0);
  set lastEventId(int id) => _makeSetter(_storage, 'last-event-id', id);
}
