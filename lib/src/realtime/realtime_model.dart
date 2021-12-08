part of qiscus_chat_sdk.usecase.realtime;

abstract class RealtimeEvent {
  static List<RealtimeEvent> fromJson(Map<String, dynamic> json) {
    var events = (json['events'] as List).cast<Map<String, dynamic>>();
    var results = events.map<List<RealtimeEvent>>((event) {
      List<RealtimeEvent> result;
      switch (event['action_topic'] as String) {
        case 'read':
          result = [MessageReadEvent.fromJson(event)];
          break;
        case 'delivered':
          result = [MessageDeliveredEvent.fromJson(event)];
          break;
        case 'clear_room':
          result = RoomClearedEvent.fromJson(event);
          break;
        case 'delete_message':
          result = MessageDeletedEvent.fromJson(event);
          break;
        default:
          result = [UnknownEvent.fromJson(event)];
          break;
      }

      return result;
    });


    return results.expand((it) => it).toList();
  }

  Out fold<Out>({
    required Out Function(UnknownEvent) unknown,
    required Out Function(MessageReadEvent) messageRead,
    required Out Function(MessageDeliveredEvent) messageDelivered,
    required Out Function(MessageDeletedEvent) messageDeleted,
    required Out Function(RoomClearedEvent) roomCleared,
  }) {
    if (this is MessageReadEvent) {
      return messageRead(this as MessageReadEvent);
    }
    if (this is MessageDeliveredEvent) {
      return messageDelivered(this as MessageDeliveredEvent);
    }

    if (this is MessageDeletedEvent) {
      return messageDeleted(this as MessageDeletedEvent);
    }
    if (this is RoomClearedEvent) {
      return roomCleared(this as RoomClearedEvent);
    }
    return unknown(this as UnknownEvent);
  }

  void flow({
    required void Function(UnknownEvent) unknown,
    required void Function(MessageReadEvent) messageRead,
    required void Function(MessageDeliveredEvent) messageDelivered,
    required void Function(MessageDeletedEvent) messageDeleted,
    required void Function(RoomClearedEvent) roomCleared,
  }) {
    fold<void>(
      unknown: unknown,
      messageRead: messageRead,
      messageDelivered: messageDelivered,
      messageDeleted: messageDeleted,
      roomCleared: roomCleared,
    );
  }
}

class UnknownEvent extends RealtimeEvent with EquatableMixin {
  UnknownEvent({required this.actionType});
  final String actionType;
  @override
  List<Object> get props => [];

  @override
  factory UnknownEvent.fromJson(Map<String, dynamic> json) {
    return UnknownEvent(actionType: json['action_topic'] as String);
  }
}

class MessageReadEvent extends RealtimeEvent with EquatableMixin {
  MessageReadEvent({
    required this.messageId,
    required this.roomId,
    required this.messageUniqueId,
    required this.userId,
  });

  final int messageId, roomId;
  final String messageUniqueId, userId;

  @override
  List<Object> get props => [userId, roomId, messageId, messageUniqueId];

  factory MessageReadEvent.fromJson(Map<String, dynamic> json) {
    var data = json['payload']['data'] as Map<String, dynamic>;
    return MessageReadEvent(
      messageId: data['comment_id'] as int,
      messageUniqueId: data['comment_unique_id'] as String,
      roomId: data['room_id'] as int,
      userId: data['email'] as String,
    );
  }
}

class MessageDeliveredEvent extends RealtimeEvent with EquatableMixin {
  MessageDeliveredEvent({
    required this.userId,
    required this.roomId,
    required this.messageId,
    required this.messageUniqueId,
  });

  final int messageId, roomId;
  final String messageUniqueId, userId;

  @override
  List<Object> get props => [userId, roomId, messageId, messageUniqueId];

  factory MessageDeliveredEvent.fromJson(Map<String, dynamic> json) {
    var data = json['payload']['data'] as Map<String, dynamic>;
    return MessageDeliveredEvent(
      messageId: data['comment_id'] as int,
      messageUniqueId: data['comment_unique_id'] as String,
      roomId: data['room_id'] as int,
      userId: data['email'] as String,
    );
  }
}

class MessageDeletedEvent extends RealtimeEvent with EquatableMixin {
  MessageDeletedEvent({
    required this.roomId,
    required this.messageUniqueId,
  });

  final int roomId;
  final String messageUniqueId;

  @override
  List<Object> get props => [roomId, messageUniqueId];

  static List<MessageDeletedEvent> fromJson(Map<String, dynamic> json) {
    var data = json['payload'] as Map<String, dynamic>;
    var deletedMessages = (data['deleted_messages'] as List) //
        .cast<Map<String, dynamic>>();

    return deletedMessages
        .map((it) {
          return (it['message_unique_ids'] as List).cast<String>().map((id) {
            return MessageDeletedEvent(
              messageUniqueId: id,
              roomId: int.parse(it['room_id'] as String),
            );
          });
        })
        .expand((it) => it)
        .toList();
  }
}

class RoomClearedEvent extends RealtimeEvent with EquatableMixin {
  RoomClearedEvent({
    required this.roomId,
  });

  final int roomId;

  @override
  List<Object> get props => [roomId];

  static List<RoomClearedEvent> fromJson(Map<String, dynamic> json) {
    var data = json['payload'] as Map<String, dynamic>;
    var deletedRooms = (data['deleted_rooms'] as List) //
        .cast<Map<String, dynamic>>();
    return deletedRooms.map((it) {
      return RoomClearedEvent(roomId: it['id'] as int);
    }).toList();
  }
}

class MessageReceivedEvent extends RealtimeEvent {
  MessageReceivedEvent({required this.message});

  final Message message;
}

class UserTypingEvent extends RealtimeEvent {
  UserTypingEvent({
    required this.userId,
    required this.isTyping,
    required this.roomId,
  });

  final String userId;
  final bool isTyping;
  final int roomId;
}

class UserPresenceEvent extends RealtimeEvent {
  UserPresenceEvent({
    required this.userId,
    required this.lastSeen,
    required this.isOnline,
  });

  final String userId;
  final DateTime lastSeen;
  final bool isOnline;
}
