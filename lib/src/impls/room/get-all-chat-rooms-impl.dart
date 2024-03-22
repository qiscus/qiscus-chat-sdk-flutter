import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/room/room-model.dart';
import 'package:qiscus_chat_sdk/src/impls/room/room-from-json-impl.dart';

ReaderTaskEither<Dio, QError, Iterable<QChatRoom>> getAllChatRoomsImpl({
  bool? showParticipant,
  bool? showRemoved,
  bool? showEmpty,
  int? limit,
  int? page,
}) {
  return Reader((Dio dio) {
    return tryCatch(() async {
      var req = GetAllRoomRequest(
        withParticipants: showParticipant,
        withEmptyRoom: showEmpty,
        withRemovedRoom: showRemoved,
        limit: limit,
        page: page,
      );
      return req(dio);
    });
  });
}

class GetAllRoomRequest extends IApiRequest<Iterable<QChatRoom>> {
  const GetAllRoomRequest({
    required this.withParticipants,
    required this.withEmptyRoom,
    required this.withRemovedRoom,
    required this.limit,
    required this.page,
  });

  final bool? withParticipants;
  final bool? withEmptyRoom;
  final bool? withRemovedRoom;
  final int? limit;
  final int? page;

  @override
  String get url => 'user_rooms';

  @override
  IRequestMethod get method => IRequestMethod.get;

  @override
  Json get params => <String, dynamic>{
        'show_participants': withParticipants,
        'show_empty': withEmptyRoom,
        'show_removed': withRemovedRoom,
        'limit': limit,
        'page': page,
      };

  @override
  Iterable<QChatRoom> format(Json json) sync* {
    var rooms = ((json['results'] as Map?)?['rooms_info'] as List) //
        .cast<Json>();

    for (var item in rooms) {
      yield roomFromJson(item);
    }
  }
}
