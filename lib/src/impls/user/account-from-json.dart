import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/user/user-model.dart';

QAccount accountFromJson(Json json) {
  return QAccount(
    id: json['email'] as String,
    name: json['username'] as String,
    avatarUrl: json['avatar_url'] as String,
    lastMessageId: (json['last_comment_id'] as int),
    lastEventId: (json['last_sync_event_id'] as int),
    extras: Option.fromNullable(json['extras'] as Object)
        .flatMap(decodeJson)
        .toNullable(),
  );
}

Map<String, Object?> accountToJson(QAccount account) {
  return <String, Object?>{
    'email': account.id,
    'username': account.name,
    'avatar_url': account.avatarUrl,
    'last_comment_id': account.lastMessageId,
    'last_sync_event_id': account.lastEventId,
    'extras': account.extras,
  };
}
