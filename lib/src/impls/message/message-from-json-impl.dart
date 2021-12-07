
import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/message/message-model.dart';
import 'package:qiscus_chat_sdk/src/domain/user/user-model.dart';

QMessage messageFromJson(Json json) {
  var extras = Option.fromNullable(json['extras']).flatMap(decodeJson);
  var payload = Option.fromNullable(json['payload']).flatMap(decodeJson);
  var status = Option.fromNullable(json['status'] as String?).map((status) {
    switch (status) {
      case 'read':
        return QMessageStatus.read;
      case 'delivered':
        return QMessageStatus.delivered;
      case 'sent':
      default:
        return QMessageStatus.sent;
    }
  }).getOrElse(() => QMessageStatus.sent);
  var type = Option.of(json['type'] as String).map((type) {
    switch (type) {
      case 'custom':
        return QMessageType.custom;
      case 'file_attachment':
        return QMessageType.attachment;
      case 'text':
      default:
        return QMessageType.text;
    }
  }).getOrElse(() => QMessageType.text);
  var timestamp = DateTime.fromMillisecondsSinceEpoch(
    ((json['unix_nano_timestamp'] as int) / 1e6).round(),
    isUtc: true,
  );

  var sender = QUser(
    id: json['email'] as String,
    name: json['username'] as String,
    avatarUrl: json['user_avatar_url'] as String,
  );

  return QMessage(
    id: json['id'] as int,
    chatRoomId: json['room_id'] as int,
    previousMessageId: json['comment_before_id'] as int,
    uniqueId: json['unique_temp_id'] as String,
    text: json['message'] as String,
    status: status,
    type: type,
    extras: extras.toNullable(),
    payload: payload.toNullable(),
    timestamp: timestamp,
    sender: sender,
  );
}
