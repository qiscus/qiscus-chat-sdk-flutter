import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/room/room-model.dart';
import 'package:qiscus_chat_sdk/src/impls/message/message-from-json-impl.dart';
import 'package:qiscus_chat_sdk/src/impls/user/participant-from-json-impl.dart';

QChatRoom roomFromJson(Json json) {
  var participants = Option.fromNullable((json['participants'] as List?))
      .map((it) => it.cast<Json>())
      .map((it) => it.map((json) => participantFromJson(json)))
      .map((it) => it.toList());

  var lastMessage = Option.fromNullable(json['last_comment'] as Json?)
      .map((it) => messageFromJson(it));

  Option<QRoomType> _type;
  var jsonType = json['chat_type'] as String;
  var isChannel = json['is_public_channel'] as bool;

  if (isChannel) {
    _type = Option.of(QRoomType.channel);
  } else if (jsonType == 'single') {
    _type = Option.of(QRoomType.single);
  } else if (jsonType == 'group') {
    _type = Option.of(QRoomType.group);
  } else {
    _type = Option.of(QRoomType.single);
  }
  return QChatRoom(
    name: (json['room_name'] as String),
    uniqueId: (json['unique_id'] as String),
    id: (json['id'] as int),
    unreadCount: (json['unread_count'] as int),
    avatarUrl: (json['avatar_url'] as String),
    extras: Option.of(json['options'] as Object) //
        .flatMap(decodeJson)
        .toNullable(),
    participants: participants.getOrElse(() => []),
    type: _type.getOrElse(() => QRoomType.single),
    lastMessage: lastMessage.toNullable(),
  );
}
