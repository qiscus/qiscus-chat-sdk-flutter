part of qiscus_chat_sdk.usecase.room;

class ChatRoom {
  Option<QRoomType> type;
  Option<String> name, avatarUrl, uniqueId;
  Option<int> totalParticipants, unreadCount, id;
  Option<Map<String, dynamic>> extras;
  Option<List<Participant>> participants;
  Option<Message> lastMessage;

  ChatRoom._({
    this.uniqueId,
    this.type,
    this.id,
    this.name,
    this.unreadCount,
    this.avatarUrl,
    this.totalParticipants,
    this.extras,
    this.participants,
    this.lastMessage,
  });

  factory ChatRoom({
    Option<String> uniqueId,
    Option<QRoomType> type,
    Option<int> id,
    Option<String> name,
    Option<int> unreadCount,
    Option<String> avatarUrl,
    Option<int> totalParticipants,
    Option<Map<String, dynamic>> extras,
    Option<List<Participant>> participants,
    Option<Message> lastMessage,
  }) {
    return ChatRoom._(
      uniqueId: uniqueId ?? Option.none(),
      type: type ?? Option.none(),
      id: id ?? Option.none(),
      name: name ?? Option.none(),
      unreadCount: unreadCount ?? Option.none(),
      avatarUrl: avatarUrl ?? Option.none(),
      totalParticipants: totalParticipants ?? Option.none(),
      extras: extras ?? Option.none(),
      participants: participants ?? Option.none(),
      lastMessage: lastMessage ?? Option.none(),
    );
  }

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    var participants = Option.of((json['participants'] as List))
        .map((it) => it.cast<Map<String, dynamic>>())
        .map((it) => it.map((json) => Participant.fromJson(json)))
        .map((it) => it.toList());
    var lastMessage = Either.tryCatch(
      () => Message.fromJson(json['last_comment'] as Map<String, dynamic>),
    );

    Option<QRoomType> _type;
    var jsonType = json['chat_type'] as String;
    var isChannel = json['is_public_channel'] as bool;

    if (isChannel) {
      _type = Option.some(QRoomType.channel);
    } else if (jsonType == 'single') {
      _type = Option.some(QRoomType.single);
    } else if (jsonType == 'group') {
      _type = Option.some(QRoomType.group);
    } else {
      _type = Option.some(QRoomType.single);
    }
    return ChatRoom(
      name: Option.of(json['room_name'] as String),
      uniqueId: Option.of(json['unique_id'] as String),
      id: Option.of(json['id'] as int),
      unreadCount: Option.of(json['unread_count'] as int),
      avatarUrl: Option.of(json['avatar_url'] as String),
      totalParticipants: Option.of(json['room_total_participants'] as int),
      extras: Option.of(json['options'] as Object).flatMap(decodeJson),
      participants: participants,
      type: _type,
      lastMessage: lastMessage.toOption(),
    );
  }

  QChatRoom toModel() => QChatRoom(
        uniqueId: uniqueId.toNullable(),
        id: id.toNullable(),
        avatarUrl: avatarUrl.toNullable(),
        extras: extras.toNullable(),
        lastMessage: lastMessage.map((it) => it.toModel()).toNullable(),
        name: name.toNullable(),
        participants: participants
            .getOrElse(() => <Participant>[])
            .map((it) => it.toModel())
            .toList(),
        totalParticipants: participants.getOrElse(() => []).length,
        type: type.toNullable(),
        unreadCount: unreadCount.toNullable(),
      );
}

class QChatRoom {
  int id, unreadCount, totalParticipants;
  String name, uniqueId, avatarUrl;
  Map<String, dynamic> extras;
  QMessage lastMessage;
  QRoomType type;
  List<QParticipant> participants;

  QChatRoom({
    @required this.id,
    this.name,
    this.uniqueId,
    this.unreadCount,
    this.avatarUrl,
    this.totalParticipants,
    this.extras,
    this.participants,
    this.lastMessage,
    this.type,
  });

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
