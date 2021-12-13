import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/message/message-model.dart';

import 'message/message-from-json-impl.dart';

RTE<Tuple2<int, Iterable<QMessage>>> synchronizeImpl([String? lastMessageId]) {
  var req = SynchronizeRequest(lastMessageId: lastMessageId);
  return Reader((dio) => tryCatch(() => req.call(dio)));
}

RTE<Tuple2<int, Iterable<QRealtimeEvent>>> synchronizeEventImpl([int? lastEventId]) {
  var req = SynchronizeEventRequest(lastEventId: lastEventId);
  return Reader((dio) => tryCatch(() => req.call(dio)));
}

class SynchronizeRequest extends IApiRequest<Tuple2<int, Iterable<QMessage>>> {
  final String? lastMessageId;

  SynchronizeRequest({
    this.lastMessageId = '0',
  });

  @override
  String get url => 'sync';
  @override
  IRequestMethod get method => IRequestMethod.get;
  @override
  Map<String, dynamic> get params => <String, dynamic>{
        'last_received_comment_id': lastMessageId,
      };

  @override
  Tuple2<int, Iterable<QMessage>> format(Map<String, dynamic> json) {
    var lastId = json['results']['meta']['last_received_comment_id'] as int;
    var messages = (json['results']['comments'] as List)
        .cast<Map<String, dynamic>>()
        .map((it) => messageFromJson(it))
        .toList();

    return Tuple2(lastId, messages);
  }
}

class SynchronizeEventRequest
    extends IApiRequest<Tuple2<int, Iterable<QRealtimeEvent>>> {
  SynchronizeEventRequest({
    this.lastEventId = 0,
  });

  final int? lastEventId;

  @override
  String get url => 'sync_event';
  @override
  IRequestMethod get method => IRequestMethod.get;
  @override
  Map<String, dynamic> get params => <String, dynamic>{
        'start_event_id': lastEventId,
      };

  @override
  Tuple2<int, Iterable<QRealtimeEvent>> format(Map<String, dynamic> json) {
    final data = (json['events'] as List).cast<Map<String, dynamic>>();
    final id = data.isNotEmpty ? data.last['id'] as int : 0;
    return Tuple2(id, QRealtimeEvent.fromJson(json));
  }
}

abstract class QRealtimeEvent {
  static Iterable<QRealtimeEvent> fromJson(Map<String, dynamic> json) {
    var events = (json['events'] as List).cast<Map<String, dynamic>>();
    var results = events.map<Iterable<QRealtimeEvent>>((event) {
      Iterable<QRealtimeEvent> result;
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

class UnknownEvent extends QRealtimeEvent with EquatableMixin {
  UnknownEvent({required this.actionType});
  final String actionType;
  @override
  List<Object> get props => [];

  @override
  factory UnknownEvent.fromJson(Map<String, dynamic> json) {
    return UnknownEvent(actionType: json['action_topic'] as String);
  }
}

class MessageReadEvent extends QRealtimeEvent with EquatableMixin {
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

class MessageDeliveredEvent extends QRealtimeEvent with EquatableMixin {
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

class MessageDeletedEvent extends QRealtimeEvent with EquatableMixin {
  MessageDeletedEvent({
    required this.roomId,
    required this.messageUniqueId,
  });

  final int roomId;
  final String messageUniqueId;

  @override
  List<Object> get props => [roomId, messageUniqueId];

  static Iterable<MessageDeletedEvent> fromJson(Map<String, dynamic> json) {
    var data = json['payload'] as Map<String, dynamic>;
    var deletedMessages = (data['deleted_messages'] as List) //
        .cast<Map<String, dynamic>>();

    return deletedMessages.map((it) {
      return (it['message_unique_ids'] as List).cast<String>().map((id) {
        return MessageDeletedEvent(
          messageUniqueId: id,
          roomId: int.parse(it['room_id'] as String),
        );
      });
    }).expand((it) => it);
  }
}

class RoomClearedEvent extends QRealtimeEvent with EquatableMixin {
  RoomClearedEvent({
    required this.roomId,
  });

  final int roomId;

  @override
  List<Object> get props => [roomId];

  static Iterable<RoomClearedEvent> fromJson(Map<String, dynamic> json) {
    var data = json['payload'] as Map<String, dynamic>;
    var deletedRooms = (data['deleted_rooms'] as List) //
        .cast<Map<String, dynamic>>();
    return deletedRooms.map((it) {
      return RoomClearedEvent(roomId: it['id'] as int);
    });
  }
}

class MessageReceivedEvent extends QRealtimeEvent {
  MessageReceivedEvent({required this.message});

  final QMessage message;
}

class UserTypingEvent extends QRealtimeEvent {
  UserTypingEvent({
    required this.userId,
    required this.isTyping,
    required this.roomId,
  });

  final String userId;
  final bool isTyping;
  final int roomId;
}

class UserPresenceEvent extends QRealtimeEvent {
  UserPresenceEvent({
    required this.userId,
    required this.lastSeen,
    required this.isOnline,
  });

  final String userId;
  final DateTime lastSeen;
  final bool isOnline;
}
