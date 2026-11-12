part of qiscus_chat_sdk.core;

const defaultBaseUrl = 'https://api3.qiscus.com';
const defaultUploadUrl = '$defaultBaseUrl/api/v2/sdk/upload';
const defaultBrokerUrl = 'realtime-bali.qiscus.com';
const defaultBrokerLbUrl = 'https://realtime-lb.qiscus.com';
const defaultAccInterval = 1000;
const defaultSyncInterval = 5000;
const defaultSyncIntervalWhenConnected = 30000;

/// Batas jumlah pesan di [Storage.messages]; pesan terlama dibuang lebih dulu.
const maxStoredMessages = 2000;

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
  Set<QChatRoom> rooms;

  /// Pesan yang dikenal SDK, dipakai untuk mencocokkan event status
  /// (delivered/read/deleted/updated) ke pesannya.
  ///
  /// Setter-nya menormalkan isi: satu entri per pesan (id ATAU uniqueId sama
  /// = pesan yang sama, instance terbaru menang), status tidak pernah turun,
  /// dan dibatasi [maxStoredMessages] entri terbaru. `QMessage` tidak punya
  /// `==`/`hashCode`, jadi `Set` biasa tidak bisa membuang duplikat ini.
  Set<QMessage> get messages => _messages;
  set messages(Set<QMessage> value) => _messages = _normalizeMessages(value);
  Set<QMessage> _messages;

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
    Set<QMessage> messages = const {},
    this.rooms = const {},
    this.configExtras = const {},
  }) : _messages = _normalizeMessages(messages);

  String? get userId => currentUser?.id;
}

extension StorageX on Storage {
  void clear() {
    currentUser = null;
    token = null;
    messages = {};
    rooms = {};
  }

  /// Menggeser cursor pesan terakhir, dan hanya ke depan.
  ///
  /// Pesan bisa tiba tidak berurutan (batch sync datang menurun, pesan lama
  /// menyalip lewat jalur lain). Kalau cursor ikut mundur, sync berikutnya
  /// menarik ulang pesan yang sudah diterima.
  void setLastMessageId(int messageId) {
    var current = currentUser?.lastMessageId ?? lastMessageId;
    if (messageId <= current) return;

    lastMessageId = messageId;
    currentUser?.lastMessageId = messageId;
  }

  /// Menggeser cursor event sync (`sync_event`), dan hanya ke depan.
  ///
  /// Respons kosong mengembalikan id 0, dan `synchronizeEvent()` bisa dipanggil
  /// dengan id lama; keduanya tidak boleh memundurkan cursor.
  void setLastEventId(int eventId) {
    var current = currentUser?.lastEventId ?? lastEventId;
    if (eventId <= current) return;

    lastEventId = eventId;
    currentUser?.lastEventId = eventId;
  }

  bool get isLogin => currentUser != null && token != null;
}

/// Urutan status yang hanya boleh naik. `sending`/`failed` di luar urutan ini
/// dan tidak pernah ikut digabung.
const _statusRank = [
  QMessageStatus.sent,
  QMessageStatus.delivered,
  QMessageStatus.read,
];

/// Lihat [Storage.messages]. Urutan dipertahankan (terlama dulu); duplikat
/// diganti instance yang datang belakangan, di posisi instance tersebut.
Set<QMessage> _normalizeMessages(Iterable<QMessage> messages) {
  var byId = <int, QMessage>{};
  var byUniqueId = <String, QMessage>{};
  var kept = <QMessage>[];

  // Telusuri dari yang terbaru supaya instance terbaru yang disimpan.
  for (var message in messages.toList().reversed) {
    var newer = byId[message.id] ??
        (message.uniqueId.isEmpty ? null : byUniqueId[message.uniqueId]);

    if (newer != null) {
      var newerRank = _statusRank.indexOf(newer.status);
      var olderRank = _statusRank.indexOf(message.status);
      if (newerRank >= 0 && olderRank > newerRank) {
        newer.status = message.status;
      }
      continue;
    }

    if (kept.length >= maxStoredMessages) break;
    kept.add(message);
    byId[message.id] = message;
    if (message.uniqueId.isNotEmpty) byUniqueId[message.uniqueId] = message;
  }

  return kept.reversed.toSet();
}
