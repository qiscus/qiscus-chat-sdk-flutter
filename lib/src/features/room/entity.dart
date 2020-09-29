part of qiscus_chat_sdk.usecase.room;

class ChatRoom {
  Option<QRoomType> type;
  Option<String> name, avatarUrl, uniqueId;
  Option<int> totalParticipants, unreadCount, id;
  Option<IMap<String, dynamic>> extras;
  Option<ISet<Participant>> participants;
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
    Option<IMap<String, dynamic>> extras,
    Option<ISet<Participant>> participants,
    Option<Message> lastMessage,
  }) {
    return ChatRoom._(
      uniqueId: uniqueId ?? none(),
      type: type ?? none(),
      id: id ?? none(),
      name: name ?? none(),
      unreadCount: unreadCount ?? none(),
      avatarUrl: avatarUrl ?? none(),
      totalParticipants: totalParticipants ?? none(),
      extras: extras ?? none(),
      participants: participants ?? none(),
      lastMessage: lastMessage ?? none(),
    );
  }

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    var participants = optionOf((json['participants'] as List))
        .map((it) => it.cast<Map<String, dynamic>>())
        .map((it) => it.map((json) => Participant.fromJson(json)))
        .map((it) => isetWithOrder(Participant.participantOrder, it));
    var lastMessage = catching<Message>(
      () => Message.fromJson(json['last_comment'] as Map<String, dynamic>),
    );

    Option<QRoomType> _type;
    var jsonType = json['chat_type'] as String;
    var isChannel = json['is_public_channel'] as bool;

    if (isChannel) {
      _type = some(QRoomType.channel);
    } else if (jsonType == 'single') {
      _type = some(QRoomType.single);
    } else if (jsonType == 'group') {
      _type = some(QRoomType.group);
    } else {
      _type = some(QRoomType.single);
    }
    return ChatRoom(
      name: optionOf(json['room_name'] as String),
      uniqueId: optionOf(json['unique_id'] as String),
      id: optionOf(json['id'] as int),
      unreadCount: optionOf(json['unread_count'] as int),
      avatarUrl: optionOf(json['avatar_url'] as String),
      totalParticipants: optionOf(json['room_total_participants'] as int),
      extras: optionOf(json['options'] as Object).bind(decodeJson).map(imap),
      participants: participants,
      type: _type,
      lastMessage: lastMessage.toOption(),
    );
  }

  QChatRoom toModel() => QChatRoom(
        uniqueId: uniqueId.toNullable(),
        id: id.toNullable(),
        avatarUrl: avatarUrl.toNullable(),
        extras: extras.map((it) => it.toMap()).toNullable(),
        lastMessage: lastMessage.map((it) => it.toModel()).toNullable(),
        name: name.toNullable(),
        participants: participants.getOrElse(() => emptySet()).foldMap(
              monoid(() => [], (a1, a2) => a1 + a2),
              (a) => [a.toModel()],
            ),
        totalParticipants: participants.getOrElse(() => emptySet()).length(),
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
