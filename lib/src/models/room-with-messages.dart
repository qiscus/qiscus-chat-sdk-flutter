import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/message/message-model.dart';
import '../domain/room/room-model.dart';
import '../domain/user/user-model.dart';

part 'room-with-messages.freezed.dart';

@freezed
class QChatRoom with _$QChatRoom {
  const factory QChatRoom({
    required int id,
    required String uniqueId,
    required String name,
    String? avatarUrl,
    Map<String, Object?>? extras,
    QMessage? lastMessage,
    @Default(0) int unreadCount,
    @Default(0) int totalParticipants,
    @Default(<QParticipant>[]) List<QParticipant> participants,
    @Default(QRoomType.single) QRoomType type,
    @Default(<QMessage>[]) List<QMessage> messages,
  }) = _QChatRoom;
}
