import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/message/message-model.dart';
import 'package:qiscus_chat_sdk/src/domain/room/room-model.dart';
import 'package:qiscus_chat_sdk/src/impls/message/message-from-json-impl.dart';
import 'package:qiscus_chat_sdk/src/impls/room/room-from-json-impl.dart';

ReaderTaskEither<Dio, String, Tuple2<QChatRoom, Iterable<QMessage>>>
    getRoomWithMessagesImpl(int roomId) {
  return Reader((dio) {
    return tryCatch(() async {
      var req = GetRoomByIdRequest(roomId: roomId);
      return req(dio);
    });
  });
}

class GetRoomByIdRequest
    extends IApiRequest<Tuple2<QChatRoom, Iterable<QMessage>>> {
  const GetRoomByIdRequest({
    required this.roomId,
  });

  final int roomId;

  @override
  String get url => 'get_room_by_id';

  @override
  IRequestMethod get method => IRequestMethod.get;

  @override
  Json get params => <String, dynamic>{'id': roomId};

  @override
  Tuple2<QChatRoom, Iterable<QMessage>> format(Json json) {
    var results = json['results'] as Json;
    var room = roomFromJson(results['room'] as Json);
    var messages = (results['comments'] as List) //
        .cast<Json>()
        .map((it) => messageFromJson(it));

    return Tuple2(room, messages);
  }
}
