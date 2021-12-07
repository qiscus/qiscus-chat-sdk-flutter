import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/domain/user/user-model.dart';
import 'package:qiscus_chat_sdk/src/core.dart';

QUser userFromJson(Json json) {
  return QUser(
    id: (json['email'] as String),
    name: (json['username'] as String),
    avatarUrl: (json['avatar_url'] as String),
    extras: Option.fromNullable(json['extras'] as Object) //
        .flatMap(decodeJson)
        .toNullable(),
  );
}
