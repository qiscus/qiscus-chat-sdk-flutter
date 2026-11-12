import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/message/message-model.dart';
import 'package:qiscus_chat_sdk/src/impls/sync.dart';

/// Receipt delivered/read untuk pesan [messageId] di room [roomId], dari MQTT
/// (`r/<roomId>/<messageId>/<userId>/d|r`) atau dari `sync_event`.
class MessageReceipt {
  const MessageReceipt({
    required this.status,
    required this.messageId,
    required this.messageUniqueId,
    this.roomId,
    this.userId,
  });

  /// [QMessageStatus.delivered] atau [QMessageStatus.read].
  final QMessageStatus status;
  final int? messageId;
  final String messageUniqueId;
  final int? roomId;

  /// User yang mengirim receipt (yang menerima/membaca pesan).
  final String? userId;

  /// Receipt dari pesan MQTT di topic delivered/read; `null` untuk topic lain.
  static MessageReceipt? fromMqtt(String topic, String payload) {
    var delivered = reDelivery.firstMatch(topic);
    var read = delivered == null ? reRead.firstMatch(topic) : null;
    var match = delivered ?? read;
    if (match == null) return null;

    var data = payload.split(':');
    return MessageReceipt(
      status: delivered != null
          ? QMessageStatus.delivered
          : QMessageStatus.read,
      messageId: int.tryParse(data[0]),
      messageUniqueId: data.length > 1 ? data.sublist(1).join(':') : '',
      roomId: int.tryParse(match.group(1)!),
      userId: match.group(3),
    );
  }

  /// Receipt dari event `sync_event`; `null` untuk event selain
  /// delivered/read.
  static MessageReceipt? fromRealtimeEvent(QRealtimeEvent event) {
    return event.fold<MessageReceipt?>(
      messageDelivered: (e) => MessageReceipt(
        status: QMessageStatus.delivered,
        messageId: e.messageId,
        messageUniqueId: e.messageUniqueId,
        roomId: e.roomId,
        userId: e.userId,
      ),
      messageRead: (e) => MessageReceipt(
        status: QMessageStatus.read,
        messageId: e.messageId,
        messageUniqueId: e.messageUniqueId,
        roomId: e.roomId,
        userId: e.userId,
      ),
      messageDeleted: (_) => null,
      roomCleared: (_) => null,
      unknown: (_) => null,
    );
  }
}

/// Urutan status yang hanya boleh naik.
const _statusRank = [
  QMessageStatus.sending,
  QMessageStatus.sent,
  QMessageStatus.delivered,
  QMessageStatus.read,
];

/// Terapkan [receipt] ke [messages] dan kembalikan pesan yang statusnya
/// benar-benar berubah, terlama dulu.
///
/// Semantik Qiscus (sama dengan SDK JS): receipt untuk pesan X di room R
/// berarti semua pesan milik user di R dengan id <= X juga sudah
/// delivered/read. Jadi yang dinaikkan adalah pesan target (dicocokkan lewat
/// id atau uniqueId) plus pesan milik [currentUserId] lain di room yang sama
/// dengan id <= X - juga bila pesan targetnya sendiri tidak dikenal.
///
/// - Hanya pesan milik [currentUserId] yang disentuh; status pesan orang lain
///   tidak bermakna di perangkat ini.
/// - Receipt yang dikirim [currentUserId] sendiri (mis. `markAsRead` dari
///   perangkat lain) diabaikan: itu bukan bukti lawan bicara sudah membaca.
/// - Status tidak pernah turun (read tidak kembali ke delivered), dan pesan
///   yang statusnya sudah setara/lebih tinggi tidak dikembalikan lagi.
/// - Pesan `sending`/`failed` hanya naik bila ia target receipt.
List<QMessage> applyMessageReceipt(
  Iterable<QMessage> messages,
  MessageReceipt receipt, {
  required String? currentUserId,
}) {
  if (currentUserId == null || receipt.userId == currentUserId) return [];

  var rank = _statusRank.indexOf(receipt.status);
  var changed = <QMessage>[];
  for (var message in messages) {
    if (message.sender.id != currentUserId) continue;

    var isTarget = (receipt.messageId != null &&
            receipt.messageId != 0 &&
            message.id == receipt.messageId) ||
        (receipt.messageUniqueId.isNotEmpty &&
            message.uniqueId == receipt.messageUniqueId);
    var isEarlier = receipt.roomId != null &&
        receipt.messageId != null &&
        message.chatRoomId == receipt.roomId &&
        message.id > 0 &&
        message.id <= receipt.messageId! &&
        message.status != QMessageStatus.sending;
    if (!isTarget && !isEarlier) continue;

    var current = _statusRank.indexOf(message.status);
    if (current < 0) {
      // `failed`: receipt untuk pesan ini membuktikan server menerimanya.
      if (!isTarget) continue;
      current = 0;
    }
    if (current >= rank) continue;

    message.status = receipt.status;
    changed.add(message);
  }

  return changed..sort((a, b) => a.id.compareTo(b.id));
}
