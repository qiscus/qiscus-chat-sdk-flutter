part of qiscus_chat_sdk.usecase.user;

class QAccount {
  String id, name, avatarUrl;
  int lastMessageId, lastEventId;
  Map<String, dynamic> extras;

  QAccount({
    @required this.id,
    this.name,
    this.avatarUrl,
    this.lastMessageId,
    this.lastEventId,
    this.extras,
  });

  @override
  String toString() => 'QAccount('
      'id=$id,'
      ' name=$name,'
      ' avatarUrl=$avatarUrl,'
      ' lastMessageId=$lastMessageId,'
      ' lastEventId=$lastEventId,'
      ' extras=$extras'
      ')';

  QUser asUser() => QUser(
        id: id,
        name: name,
        avatarUrl: avatarUrl,
        extras: extras,
      );
}

@immutable
class Account {
  final String id;
  final Option<String> name, avatarUrl;
  final Option<int> lastMessageId, lastEventId;
  final Option<Map<String, dynamic>> extras;

  Account._({
    @required this.id,
    this.name,
    this.avatarUrl,
    this.lastMessageId,
    this.lastEventId,
    this.extras,
  });

  factory Account({
    @required String id,
    Option<String> name,
    Option<String> avatarUrl,
    Option<int> lastMessageId,
    Option<int> lastEventId,
    Option<Map<String, dynamic>> extras,
  }) {
    return Account._(
      id: id,
      name: name ?? Option.none(),
      avatarUrl: avatarUrl ?? Option.none(),
      lastMessageId: lastMessageId ?? Option.none(),
      lastEventId: lastEventId ?? Option.none(),
      extras: extras ?? Option.none(),
    );
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['email'] as String,
      name: Option.of(json['username'] as String),
      avatarUrl: Option.of(json['avatar_url'] as String),
      lastMessageId: Option.of(json['last_comment_id'] as int),
      lastEventId: Option.of(json['last_sync_event_id'] as int),
      extras: Option.of(json['extras'] as Object).flatMap(decodeJson),
    );
  }

  Account copy({
    dynamic name = immutable,
    dynamic avatarUrl = immutable,
    dynamic lastMessageId = immutable,
    dynamic lastEventId = immutable,
    dynamic extras = immutable,
  }) {
    return Account(
      id: id,
      name: name == immutable ? this.name : name as Option<String>,
      avatarUrl:
          avatarUrl == immutable ? this.avatarUrl : avatarUrl as Option<String>,
      lastEventId: lastEventId == immutable
          ? this.lastEventId
          : lastEventId as Option<int>,
      lastMessageId: lastMessageId == immutable
          ? this.lastMessageId
          : lastMessageId as Option<int>,
      extras: extras == immutable
          ? this.extras
          : extras as Option<Map<String, dynamic>>,
    );
  }

  QAccount toModel() {
    return QAccount(
      id: id,
      name: name.toNullable(),
      avatarUrl: avatarUrl.toNullable(),
      extras: extras.toNullable(),
      lastMessageId: lastMessageId.toNullable(),
      lastEventId: lastEventId.toNullable(),
    );
  }
}
