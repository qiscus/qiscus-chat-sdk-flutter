import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/features/message/entity.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';
import 'package:retrofit/http.dart';

part 'api.g.dart';

@RestApi()
abstract class SyncApi {
  factory SyncApi(Dio dio) = _SyncApi;

  @GET('sync')
  Future<SynchronizeResponse> synchronize(
    @Query('last_received_comment_id') int lastCommentId,
  );

  @GET('sync_event')
  Future<SyncEventResponse> synchronizeEvent(
    @Query('start_event_id') int eventId,
  );
}

class SynchronizeResponseSingle extends Equatable {
  final int lastMessageId;
  final Message message;

  const SynchronizeResponseSingle(this.lastMessageId, this.message);

  @override
  List<Object> get props => [lastMessageId, message];

  @override
  bool get stringify => true;
}

@immutable
class SynchronizeResponse extends Equatable {
  final int lastMessageId;
  final List<Message> messages;

  const SynchronizeResponse._(this.lastMessageId, this.messages);

  factory SynchronizeResponse.fromJson(Map<String, dynamic> json) {
    var lastMessageId =
        json['results']['meta']['last_received_comment_id'] as int;
    var messages =
        (json['results']['comments'] as List).cast<Map<String, dynamic>>();
    var messages_ = messages
        .map(
          (it) => Message.fromJson(it),
        )
        .toList();
    return SynchronizeResponse._(lastMessageId, messages_);
  }

  @override
  List<Object> get props => [lastMessageId, messages];

  @override
  bool get stringify => true;
}

@immutable
class SynchronizeEventResponse extends Equatable {
  final num id;
  final String actionType;
  final int roomId;
  final Message message;

  const SynchronizeEventResponse._({
    this.id,
    this.actionType,
    this.roomId,
    this.message,
  });

  factory SynchronizeEventResponse.fromJson(Map<String, dynamic> json) {
    /*
    {
      'events': [
        {
          'id': 1582544441796618373,
          'timestamp': 1582544441796618373,
          'action_topic': 'read',
          'payload': {
            'actor': {'id': '', 'email': '', 'name': ''},
            'data': {
              'comment_id': 163469566,
              'comment_unique_id': 'ck70e2xha00042663fu2510u5',
              'email': 'guest-1002',
              'room_id': 3143607
            }
          }
        }
      ],
      'is_start_event_id_found': false,
    };
     */
    var events = json['events'] as List<Map<String, dynamic>>;
    var events_ = events.map((event) {
      var id = event['id'] as num;
      var actionType = event['action_topic'] as String;
    });

    return SynchronizeEventResponse._();
  }

  @override
  List<Object> get props => [id, actionType, message, roomId];

  @override
  bool get stringify => true;
}

enum SyncActionType {
  messageRead,
  messageDelivered,
  messageDeleted,
  roomCleared,
  unknown,
}

class SyncEventResponseSingle extends Equatable {
  final int id;
  final SyncActionType actionType;
  final Message message;
  final int messageId;
  final String messageUniqueId;
  final int roomId;

  const SyncEventResponseSingle({
    @required this.id,
    @required this.actionType,
    @required this.roomId,
    @required this.messageId,
    @required this.messageUniqueId,
    this.message,
  });

  @override
  List<Object> get props => [
        id,
        actionType,
        roomId,
        messageUniqueId,
      ];
  @override
  bool get stringify => true;
}

class SyncEventResponse extends Equatable {
  final List<SyncEventResponseSingle> events;

  const SyncEventResponse._(this.events);

  /*
    {
      'events': [
        {
          'id': 1582544441796618373,
          'timestamp': 1582544441796618373,
          'action_topic': 'read',
          'payload': {
            'actor': {'id': '', 'email': '', 'name': ''},
            'data': {
              'comment_id': 163469566,
              'comment_unique_id': 'ck70e2xha00042663fu2510u5',
              'email': 'guest-1002',
              'room_id': 3143607
            }
          }
        }
      ],
      'is_start_event_id_found': false,
    };
     */
  factory SyncEventResponse.fromJson(Map<String, dynamic> json) {
    var events = (json['events'] as List).cast<Map<String, dynamic>>();
    var _events = events.map<SyncEventResponseSingle>((event) {
      var eventId = event['id'] as int;
      SyncActionType actionType = ((String topic) {
        switch (topic) {
          case 'delivered':
            return SyncActionType.messageDelivered;
          case 'deleted_message':
            return SyncActionType.messageDeleted;
          case 'clear_room':
            return SyncActionType.roomCleared;
          case 'read':
            return SyncActionType.messageRead;
          default:
            return SyncActionType.unknown;
        }
      })(event['action_topic'] as String);

      var payload = event['payload']['data'] as Map<String, dynamic>;
      var message = Message(
        id: payload['comment_id'] as int,
        uniqueId: some(payload['comment_unique_id'] as String),
        chatRoomId: some(payload['room_id'] as int),
        sender: some(User(
          id: payload['email'] as String,
        )),
      );

      var messageId = message.id;
      var messageUniqueId = message.uniqueId.getOrElse(() => null);
      var roomId = message.chatRoomId.getOrElse(() => null);

      return SyncEventResponseSingle(
        id: eventId,
        actionType: actionType,
        roomId: roomId,
        messageId: messageId,
        messageUniqueId: messageUniqueId,
        message: message,
      );
    }).toList();
    return SyncEventResponse._(_events);
  }

  @override
  List<Object> get props => [events];
  @override
  bool get stringify => true;
}
