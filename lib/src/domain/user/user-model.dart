import 'package:meta/meta.dart';

class QUser {
  const QUser({
    @required this.id,
    @required this.name,
    this.avatarUrl,
    this.extras,
  });

  final String id;
  final String name;
  final String avatarUrl;
  final Map<String, dynamic> extras;
}

class QAccount extends QUser {
  const QAccount({
    @required String id,
    @required String name,
    String avatarUrl,
    Map<String, dynamic> extras,
    this.lastEventId,
    this.lastMessageId,
  }) : super(id: id, name: name, avatarUrl: avatarUrl, extras: extras);

  final String lastEventId;
  final String lastMessageId;
}

class QParticipant extends QUser {
  const QParticipant({
    @required String id,
    @required String name,
    String avatarUrl,
    Map<String, dynamic> extras,
    this.lastReadMessageId,
    this.lastReceivedMessageId,
  }) : super(id: id, name: name, avatarUrl: avatarUrl, extras: extras);

  final int lastReadMessageId;
  final int lastReceivedMessageId;
}

class QDeviceToken {
  const QDeviceToken(this.token, [this.isDevelopment = false]);
  final String token;
  final bool isDevelopment;
  final deviceType = 'rn';
}

class QUserTyping {
  const QUserTyping({this.userId, this.roomId, this.isTyping});
  final String userId;
  final bool isTyping;
  final int roomId;
}

class QUserPresence {
  const QUserPresence({this.userId, this.lastSeen, this.isOnline});
  final String userId;
  final DateTime lastSeen;
  final bool isOnline;
}
