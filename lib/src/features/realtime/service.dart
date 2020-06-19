import 'package:dartz/dartz.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/features/message/entity.dart';

part 'service.g.dart';

abstract class RealtimeService {
  MqttClientConnectionStatus get connectionState;

  bool get isConnected;

  Either<QError, void> end();

  Task<Either<QError, void>> subscribe(String topic);

  Task<Either<QError, void>> unsubscribe(String topic);

  Stream<void> onConnected();

  Stream<void> onReconnecting();

  Stream<void> onDisconnected();

  Stream<Message> subscribeMessageReceived();

  Stream<MessageDeliveryResponse> subscribeMessageDelivered({
    @required int roomId,
  });

  Stream<CustomEventResponse> subscribeCustomEvent({
    @required int roomId,
  });

  Stream<MessageDeliveryResponse> subscribeMessageRead({
    @required int roomId,
  });

  Stream<MessageDeletedResponse> subscribeMessageDeleted();

  Stream<RoomClearedResponse> subscribeRoomCleared();

  Stream<MessageReceivedResponse> subscribeChannelMessage({
    @required String uniqueId,
  });

  Stream<UserTypingResponse> subscribeUserTyping({
    @required int roomId,
  });

  Stream<UserPresenceResponse> subscribeUserPresence({
    @required String userId,
  });

  Either<QError, void> publishTyping({
    @required bool isTyping,
    @required String userId,
    @required int roomId,
  });

  Either<QError, void> publishPresence({
    bool isOnline,
    DateTime lastSeen,
    String userId,
  });

  Either<QError, void> publishCustomEvent({
    @required int roomId,
    @required Map<String, dynamic> payload,
  });

  Task<Either<QError, Unit>> synchronize([int lastMessageId]);
  Task<Either<QError, Unit>> synchronizeEvent([String lastEventId]);
}

class CustomEventResponse {
  const CustomEventResponse(this.roomId, this.payload);

  final int roomId;
  final Map<String, dynamic> payload;
}

@JsonSerializable()
class MessageReceivedResponse {
  final int id, comment_before_id;
  final String message,
      username,
      email,
      user_avatar,
      timestamp,
      unix_timestamp,
      created_at,
      room_id,
      room_name,
      topic_id,
      unique_temp_id,
      chat_type;
  final bool disable_link_preview;

  MessageReceivedResponse({
    this.id,
    this.comment_before_id,
    this.message,
    this.username,
    this.user_avatar,
    this.email,
    this.timestamp,
    this.unix_timestamp,
    this.created_at,
    this.room_id,
    this.room_name,
    this.topic_id,
    this.unique_temp_id,
    this.chat_type,
    this.disable_link_preview,
  });

  factory MessageReceivedResponse.fromJson(Map<String, dynamic> json) =>
      _$MessageReceivedResponseFromJson(json);
}

@immutable
class MessageDeliveryResponse {
  final String commentId;
  final String commentUniqueId;
  final int roomId;

  const MessageDeliveryResponse({
    @required this.commentId,
    @required this.commentUniqueId,
    @required this.roomId,
  });
}

class MessageDeletedResponse {
  final String actorId, actorEmail, actorName, messageUniqueId;
  final int messageRoomId;

  MessageDeletedResponse({
    this.actorName,
    this.actorEmail,
    this.actorId,
    this.messageUniqueId,
    this.messageRoomId,
  });
}

class RoomClearedResponse {
  int room_id;

  RoomClearedResponse({this.room_id});
}

@immutable
class UserTypingResponse {
  final String userId;
  final int roomId;
  final bool isTyping;

  const UserTypingResponse({
    @required this.userId,
    @required this.roomId,
    @required this.isTyping,
  });
}

@immutable
class UserPresenceResponse {
  final String userId;
  final DateTime lastSeen;
  final bool isOnline;

  const UserPresenceResponse({
    this.userId,
    this.lastSeen,
    this.isOnline,
  });
}
