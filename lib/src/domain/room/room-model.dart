import '../message/message-model.dart';
import '../user/user-model.dart';
import '../../core.dart';

class QChatRoom {
  int id;
  int unreadCount;
  int totalParticipants;
  String? name;
  String uniqueId;
  String? avatarUrl;
  Json? extras;
  QMessage? lastMessage;
  QRoomType type;
  List<QParticipant> participants;

  QChatRoom({
    required this.id,
    required this.uniqueId,
    this.name,
    this.avatarUrl,
    this.extras,
    this.lastMessage,
    this.unreadCount = 0,
    this.participants = const [],
    this.type = QRoomType.single,
  }) : totalParticipants = participants.length;

  @override
  String toString() => 'QChatRoom('
      'id=$id, '
      'name=$name, '
      'uniqueId=$uniqueId, '
      'unreadCount=$unreadCount, '
      'avatarUrl=$avatarUrl, '
      'totalParticipants=$totalParticipants, '
      'extras=$extras, '
      'participants=$participants, '
      'lastMessage=$lastMessage, '
      'type=$type'
      ')';
}

enum QRoomType {
  single,
  group,
  channel,
}
