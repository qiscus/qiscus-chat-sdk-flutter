import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';

import 'user.dart';

@immutable
class QAccount {
  final String id, name, avatarUrl;
  final int lastMessageId, lastEventId;
  final Map<String, dynamic> extras;

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
      ' id=$id,'
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
  final Option<IMap<String, dynamic>> extras;

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
    Option<IMap<String, dynamic>> extras,
  }) {
    return Account._(
      id: id,
      name: name ?? none(),
      avatarUrl: avatarUrl ?? none(),
      lastMessageId: lastMessageId ?? none(),
      lastEventId: lastEventId ?? none(),
      extras: extras ?? none(),
    );
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['email'] as String,
      name: optionOf(json['username'] as String),
      avatarUrl: optionOf(json['avatar_url'] as String),
      lastMessageId: optionOf(json['last_comment_id'] as int),
      lastEventId: optionOf(json['last_sync_event_id'] as int),
      extras: optionOf(json['extras'] as Map<String, dynamic>).map(imap),
    );
  }

  Account copy({
    dynamic name = immutable,
    dynamic avatarUrl = immutable,
    dynamic lastMessageId = immutable,
    dynamic lastEventId = immutable,
    dynamic extras = immutable,
  }) =>
      Account(
        id: id,
        name: name == immutable ? this.name : name as Option<String>,
        avatarUrl: avatarUrl == immutable
            ? this.avatarUrl
            : avatarUrl as Option<String>,
        lastEventId: lastEventId == immutable
            ? this.lastEventId
            : lastEventId as Option<int>,
        lastMessageId: lastMessageId == immutable
            ? this.lastMessageId
            : lastMessageId as Option<int>,
        extras: extras == immutable
            ? this.extras
            : extras as Option<IMap<String, dynamic>>,
      );

  QAccount toModel() {
    return QAccount(
      id: id,
      name: name.toNullable(),
      avatarUrl: avatarUrl.toNullable(),
      extras: extras.map((it) => it.toMap()).toNullable(),
      lastMessageId: lastMessageId.toNullable(),
      lastEventId: lastEventId.toNullable(),
    );
  }
}
