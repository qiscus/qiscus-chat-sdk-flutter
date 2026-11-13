import 'package:qiscus_chat_sdk/src/core.dart';

/// Jenis topic room yang di-subscribe lewat `subscribeChatRoom()`.
enum RoomTopicKind { read, delivered, typing }

/// Subscription topic receipt (read/delivered) dan typing per room.
///
/// Tiap jenis topic dicoba dulu dengan wildcard (`r/<room>/+/+/r`,
/// `r/<room>/+/+/d`, `r/<room>/<room>/+/t`). Broker produksi
/// (`mochi-mqtt.qiscus.com`) menolak SUBSCRIBE wildcard itu (SUBACK 0x80),
/// sehingga receipt dan typing tidak pernah sampai. Bila SUBACK sebuah jenis
/// gagal, jenis itu saja yang diganti topic konkret per peserta lain
/// (`r/<room>/<room>/<email>/r|d|t`); jenis lain yang wildcard-nya diterima
/// tidak diubah.
///
/// Untuk satu jenis, wildcard dan topic per peserta tidak pernah aktif
/// bersamaan, jadi broker tidak mengirim pesan yang sama dua kali. Keduanya
/// cocok dengan regex yang sama (`reRead`, `reDelivery`, `reTyping`), sehingga
/// semua event masuk ke satu pipeline stream di `realtime.dart` apa pun topic
/// asalnya.
class RoomTopicSubscriptions {
  RoomTopicSubscriptions({
    required this.subscribe,
    required this.unsubscribe,
    required this.currentUserId,
    required this.fetchParticipants,
  });

  /// Subscribe/unsubscribe MQTT; hanya dipanggil saat terhubung.
  final void Function(String topic) subscribe;
  final void Function(String topic) unsubscribe;
  final String? Function() currentUserId;

  /// Peserta room [roomUniqueId]; set kosong bila gagal.
  final Future<Set<String>> Function(String roomUniqueId) fetchParticipants;

  /// Batas peserta untuk topic per peserta (mis. channel besar).
  static const maxParticipantTopics = 100;

  final _rooms = <int, _Room>{};

  /// Topic yang sedang di-subscribe untuk [roomId] (untuk test/debug).
  Set<String> topicsOf(int roomId) => {...?_rooms[roomId]?.topics};

  /// Mulai (atau segarkan) subscription room. Aman dipanggil berulang.
  void add(int roomId, String uniqueId, Set<String> participants) {
    var room = _rooms.putIfAbsent(roomId, () => _Room(uniqueId));
    if (participants.isNotEmpty) room.participants = participants;
    _apply(roomId, room, resubscribe: true);
  }

  void remove(int roomId) {
    var room = _rooms.remove(roomId);
    room?.topics.forEach(unsubscribe);
  }

  void clear() => _rooms.clear();

  void updateParticipants(
    int roomId, {
    Iterable<String> added = const [],
    Iterable<String> removed = const [],
  }) {
    var room = _rooms[roomId];
    if (room == null) return;
    room.participants = {...room.participants, ...added}..removeAll(removed);
    _apply(roomId, room);
  }

  /// `true` bila [topic] adalah wildcard room aktif yang belum diganti
  /// fallback, yaitu kegagalan yang ditangani [onSubscribeFail].
  bool isPendingWildcard(String topic) {
    for (var entry in _rooms.entries) {
      for (var kind in RoomTopicKind.values) {
        if (!entry.value.fallback.contains(kind) &&
            _wildcard(entry.key, kind) == topic) {
          return true;
        }
      }
    }
    return false;
  }

  /// Dipanggil dari `MqttClient.onSubscribeFail`. `true` bila [topic] adalah
  /// wildcard room yang kemudian diganti topic per peserta.
  Future<bool> onSubscribeFail(String topic) async {
    for (var entry in _rooms.entries) {
      var room = entry.value;
      for (var kind in RoomTopicKind.values) {
        if (room.fallback.contains(kind)) continue;
        if (_wildcard(entry.key, kind) != topic) continue;

        room.fallback.add(kind);
        room.topics.remove(topic); // broker sudah menolaknya
        if (room.participants.isEmpty && !room.fetched) {
          room.fetched = true;
          room.participants = await fetchParticipants(room.uniqueId);
        }
        // Room bisa sudah di-unsubscribe selama menunggu peserta.
        if (identical(_rooms[entry.key], room)) _apply(entry.key, room);
        return true;
      }
    }
    return false;
  }

  void _apply(int roomId, _Room room, {bool resubscribe = false}) {
    var desired = _desired(roomId, room);
    for (var topic in room.topics.difference(desired)) {
      unsubscribe(topic);
    }
    var toSubscribe = resubscribe ? desired : desired.difference(room.topics);
    room.topics = desired;
    toSubscribe.forEach(subscribe);
  }

  Set<String> _desired(int roomId, _Room room) {
    var others = _others(room.participants);
    return {
      for (var kind in RoomTopicKind.values)
        if (!room.fallback.contains(kind))
          _wildcard(roomId, kind)
        else
          for (var id in others) _perParticipant(roomId, kind, id),
    };
  }

  List<String> _others(Set<String> participants) {
    var me = currentUserId();
    // `+`, `#` dan `/` membuat topic filter tidak valid.
    var others = participants
        .where((id) => id.isNotEmpty && id != me)
        .where((id) => !id.contains(RegExp(r'[+#/]')))
        .toList();
    return others.length > maxParticipantTopics ? const [] : others;
  }

  static String _wildcard(int roomId, RoomTopicKind kind) {
    var room = roomId.toString();
    switch (kind) {
      case RoomTopicKind.read:
        return TopicBuilder.messageRead(room);
      case RoomTopicKind.delivered:
        return TopicBuilder.messageDelivered(room);
      case RoomTopicKind.typing:
        return TopicBuilder.typing(room, '+');
    }
  }

  static String _perParticipant(int roomId, RoomTopicKind kind, String id) {
    var room = roomId.toString();
    switch (kind) {
      case RoomTopicKind.read:
        return TopicBuilder.messageReadBy(room, id);
      case RoomTopicKind.delivered:
        return TopicBuilder.messageDeliveredBy(room, id);
      case RoomTopicKind.typing:
        return TopicBuilder.typing(room, id);
    }
  }
}

class _Room {
  _Room(this.uniqueId);

  final String uniqueId;
  Set<String> participants = {};
  bool fetched = false;

  /// Jenis yang wildcard-nya ditolak broker.
  final fallback = <RoomTopicKind>{};

  /// Topic yang sedang di-subscribe.
  Set<String> topics = {};
}
