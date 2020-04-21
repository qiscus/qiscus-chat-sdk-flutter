// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: argument_type_not_assignable, implicit_dynamic_parameter, unused_element

part of 'service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageReceivedResponse _$MessageReceivedResponseFromJson(
    Map<String, dynamic> json) {
  return MessageReceivedResponse(
    id: json['id'] as int,
    comment_before_id: json['comment_before_id'] as int,
    message: json['message'] as String,
    username: json['username'] as String,
    user_avatar: json['user_avatar'] as String,
    email: json['email'] as String,
    timestamp: json['timestamp'] as String,
    unix_timestamp: json['unix_timestamp'] as String,
    created_at: json['created_at'] as String,
    room_id: json['room_id'] as String,
    room_name: json['room_name'] as String,
    topic_id: json['topic_id'] as String,
    unique_temp_id: json['unique_temp_id'] as String,
    chat_type: json['chat_type'] as String,
    disable_link_preview: json['disable_link_preview'] as bool,
  );
}

Map<String, dynamic> _$MessageReceivedResponseToJson(
        MessageReceivedResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'comment_before_id': instance.comment_before_id,
      'message': instance.message,
      'username': instance.username,
      'email': instance.email,
      'user_avatar': instance.user_avatar,
      'timestamp': instance.timestamp,
      'unix_timestamp': instance.unix_timestamp,
      'created_at': instance.created_at,
      'room_id': instance.room_id,
      'room_name': instance.room_name,
      'topic_id': instance.topic_id,
      'unique_temp_id': instance.unique_temp_id,
      'chat_type': instance.chat_type,
      'disable_link_preview': instance.disable_link_preview,
    };
