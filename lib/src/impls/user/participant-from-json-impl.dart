import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/user/user-model.dart';

QParticipant participantFromJson(Json json) {
  return QParticipant(
    id: json['email'] as String,
    name: (json['username'] as String),
    avatarUrl: Option.fromNullable(json['avatar_url'] as String).toNullable(),
    lastReceivedMessageId:
        Option.fromNullable(json['last_comment_received_id'] as int)
            .toNullable(),
    lastReadMessageId:
        Option.fromNullable(json['last_comment_read_id'] as int)
            .toNullable(),
    extras: Option.of(json['extras'] as Object) //
        .flatMap(decodeJson)
        .toNullable(),
  );
}
