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
  final Option<Map<String, dynamic>> extras;
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
    Option<Map<String, dynamic>> extras,
  }) {
    return Participant._(
      id: id,
      name: name ?? Option.none(),
      avatarUrl: avatarUrl ?? Option.none(),
      lastReadMessageId: lastReadMessageId ?? Option.none(),
      lastReceivedMessageId: lastReceivedMessageId ?? Option.none(),
      extras: extras ?? Option.none(),
    );
  }

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['email'] as String,
      name: Option.of(json['username'] as String),
      avatarUrl: Option.of(json['avatar_url'] as String),
      lastReceivedMessageId: Option.of(
        json['last_received_comment_id'] as String,
      ).map((it) => int.tryParse(it)),
      lastReadMessageId: Option.of(json['last_read_comment_id'] as String)
          .map((it) => int.tryParse(it)),
      extras: Option.of(json['extras'] as Object).flatMap(decodeJson),
    );
  }

  QParticipant toModel() => QParticipant(
        id: id,
        name: name.toNullable(),
        avatarUrl: avatarUrl.toNullable(),
        lastReadMessageId: lastReadMessageId.toNullable(),
        lastReceivedMessageId: lastReceivedMessageId.toNullable(),
        extras: extras.toNullable(),
      );
}
