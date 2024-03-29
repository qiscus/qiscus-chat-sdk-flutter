import 'package:equatable/equatable.dart';

import '../../core.dart';

class QUser with EquatableMixin {
  const QUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.extras,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final Map<String, Object?>? extras;

  @override
  List<Object?> get props => [id];
}

class QAccount extends QUser {
  QAccount({
    required String id,
    required String name,
    String? avatarUrl,
    Json? extras,
    this.lastEventId,
    this.lastMessageId,
  }) : super(id: id, name: name, avatarUrl: avatarUrl, extras: extras);

  int? lastEventId;
  int? lastMessageId;
}

class QParticipant extends QUser {
  const QParticipant({
    required String id,
    required String name,
    String? avatarUrl,
    Json? extras,
    this.lastReadMessageId,
    this.lastReceivedMessageId,
  }) : super(id: id, name: name, avatarUrl: avatarUrl, extras: extras);

  final int? lastReadMessageId;
  final int? lastReceivedMessageId;
}

class QUserTyping with EquatableMixin {
  const QUserTyping({
    required this.userId,
    required this.roomId,
    required this.isTyping,
  });
  final String userId;
  final bool isTyping;
  final int roomId;

  @override
  List<Object?> get props => [userId, roomId];
}

class QUserPresence with EquatableMixin {
  const QUserPresence({
    required this.userId,
    required this.lastSeen,
    required this.isOnline,
  });
  final String userId;
  final DateTime lastSeen;
  final bool isOnline;

  @override
  List<Object?> get props => [userId];
}
