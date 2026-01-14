part of qiscus_chat_sdk.core;

const defaultBaseUrl = 'https://api3.qiscus.com';
const defaultUploadUrl = '$defaultBaseUrl/api/v2/sdk/upload';
const defaultBrokerUrl = 'realtime-bali.qiscus.com';
const defaultBrokerLbUrl = 'https://realtime-lb.qiscus.com';
const defaultAccInterval = 1000;
const defaultSyncInterval = 5000;
const defaultSyncIntervalWhenConnected = 30000;

class Storage {
  String? appId;
  String? version;
  String? token;
  QAccount? currentUser;
  Map<String, String> customHeaders;

  String baseUrl;
  String brokerUrl;
  String brokerLbUrl;
  String uploadUrl;
  Duration syncInterval;
  Duration syncIntervalWhenConnected;
  Duration accSyncInterval;
  bool debugEnabled;
  bool brokerLbEnabled;
  int lastMessageId;
  int lastEventId;
  bool enableEventReport;
  QLogLevel logLevel;
  bool isRealtimeEnabled;
  bool isRealtimeCheckEnabled;
  bool isSyncEnabled;
  bool isSyncEventEnabled;
  bool isRealtimeManuallyClosed;
  Json? configExtras;
  Set<QMessage> messages;
  Set<QChatRoom> rooms;

  Storage({
    this.appId,
    this.version,
    this.token,
    this.currentUser,
    this.customHeaders = const <String, String>{},
    this.baseUrl = defaultBaseUrl,
    this.brokerUrl = defaultBrokerUrl,
    this.brokerLbUrl = defaultBrokerLbUrl,
    this.uploadUrl = defaultUploadUrl,
    this.syncInterval = const Duration(seconds: 5),
    this.syncIntervalWhenConnected = const Duration(seconds: 30),
    this.accSyncInterval = const Duration(seconds: 1),
    this.debugEnabled = false,
    this.brokerLbEnabled = true,
    this.lastMessageId = 0,
    this.lastEventId = 0,
    this.enableEventReport = false,
    this.isRealtimeEnabled = true,
    this.isRealtimeCheckEnabled = false,
    this.isRealtimeManuallyClosed = false,
    this.isSyncEnabled = true,
    this.isSyncEventEnabled = false,
    this.logLevel = QLogLevel.debug,
    this.messages = const {},
    this.rooms = const {},
    this.configExtras = const {},
  });

  String? get userId => currentUser?.id;
}

extension StorageX on Storage {
  void clear() {
    currentUser = null;
    token = null;
    messages = {};
    rooms = {};
  }

  void setLastMessageId(int messageId) {
    lastMessageId = messageId;
    currentUser?.lastMessageId = messageId;
  }

  bool get isLogin => currentUser != null && token != null;
}
