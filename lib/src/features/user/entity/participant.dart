part of qiscus_chat_sdk.usecase.user;

class QParticipant {
  final String id, name, avatarUrl;
  final int lastReadMessageId, lastReceivedMessageId;
  final Map<String, dynamic> extras;
  QParticipant({
    @required this.id,
    this.name,
    this.avatarUrl,
    this.lastReadMessageId,
    this.lastReceivedMessageId,
    this.extras,
  });

  @override
  String toString() => 'QParticipant('
      'id=$id, '
      'name=$name, '
      'avatarUrl=$avatarUrl, '
      'lastReadMessageId=$lastReadMessageId, '
      'lastReceivedMessageId=$lastReceivedMessageId, '
      'extras=$extras'
      ')';

  QUser asUser() => QUser(
        id: id,
        name: name,
        avatarUrl: avatarUrl,
        extras: extras,
      );
}

class Participant {
  final String id;
  final Option<String> name, avatarUrl;
  final Option<int> lastReadMessageId, lastReceivedMessageId;
  final Option<IMap<String, dynamic>> extras;
  Participant._({
    @required this.id,
    this.name,
    this.avatarUrl,
    this.lastReceivedMessageId,
    this.lastReadMessageId,
    this.extras,
  });

  factory Participant({
    String id,
    Option<String> name,
    Option<String> avatarUrl,
    Option<int> lastReadMessageId,
    Option<int> lastReceivedMessageId,
    Option<IMap<String, dynamic>> extras,
  }) {
    return Participant._(
      id: id,
      name: name ?? none(),
      avatarUrl: avatarUrl ?? none(),
      lastReadMessageId: lastReadMessageId ?? none(),
      lastReceivedMessageId: lastReceivedMessageId ?? none(),
      extras: extras ?? none(),
    );
  }

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['email'] as String,
      name: optionOf(json['username'] as String),
      avatarUrl: optionOf(json['avatar_url'] as String),
      lastReceivedMessageId: optionOf(
        json['last_received_comment_id'] as String,
      ).map((it) => int.tryParse(it)),
      lastReadMessageId: optionOf(json['last_read_comment_id'] as String)
          .map((it) => int.tryParse(it)),
      extras: optionOf(json['extras'] as Object).bind(decodeJson).map(imap),
    );
  }

  QParticipant toModel() => QParticipant(
        id: id,
        name: name.toNullable(),
        avatarUrl: avatarUrl.toNullable(),
        lastReadMessageId: lastReadMessageId.toNullable(),
        lastReceivedMessageId: lastReceivedMessageId.toNullable(),
        extras: extras.map((it) => it.toMap()).toNullable(),
      );

  static final participantOrder = order<Participant>((p1, p2) {
    return comparableOrder<String>().order(
      p1.name.getOrElse(() => ''),
      p2.name.getOrElse(() => ''),
    );
  });
}
