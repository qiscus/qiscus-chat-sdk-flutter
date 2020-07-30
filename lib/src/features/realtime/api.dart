import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/features/message/entity.dart';
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
  Future<SynchronizeEventResponse> synchronizeEvent(
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
class SynchronizeEventResponse {
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
//    var events = json['events'] as List<Map<String, dynamic>>;
//    var events_ = events.map((event) {
//      var id = event['id'] as num;
//      var actionType = event['action_topic'] as String;
//    });
    return SynchronizeEventResponse._();
  }
}
