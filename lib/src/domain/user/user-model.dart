
class QUser {
  const QUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.extras,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final Map<String, dynamic>? extras;
}

class QAccount extends QUser {
  QAccount({
    required String id,
    required String name,
    String? avatarUrl,
    Map<String, dynamic>? extras,
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
    Map<String, dynamic>? extras,
    this.lastReadMessageId,
    this.lastReceivedMessageId,
  }) : super(id: id, name: name, avatarUrl: avatarUrl, extras: extras);

  final int? lastReadMessageId;
  final int? lastReceivedMessageId;
}

class QDeviceToken {
  const QDeviceToken(this.token, [this.isDevelopment = false]);
  final String token;
  final bool isDevelopment;
  final deviceType = 'flutter';
}

class QUserTyping {
  const QUserTyping({
    required this.userId,
    required this.roomId,
    required this.isTyping,
  });
  final String userId;
  final bool isTyping;
  final int roomId;
}

class QUserPresence {
  const QUserPresence({
    required this.userId,
    required this.lastSeen,
    required this.isOnline,
  });
  final String userId;
  final DateTime lastSeen;
  final bool isOnline;
}


