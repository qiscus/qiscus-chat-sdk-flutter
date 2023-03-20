import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import 'package:qiscus_chat_sdk/src/domain/room/room-model.dart';
import 'package:qiscus_chat_sdk/src/impls/room/room-from-json-impl.dart';

ReaderTaskEither<Dio, String, Iterable<QChatRoom>> getChatRoomsImpl({
  Iterable<int>? roomIds,
  Iterable<String>? uniqueIds,
  int? page,
  bool? showRemoved,
  bool? showParticipants,
}) {
  return Reader((dio) {
    if ([roomIds, uniqueIds].every((it) => it == null)) {
      return TaskEither<String, Iterable<QChatRoom>>.left(
          'Please specify either `roomIds` or `uniqueIds`');
    }
    if ([roomIds, uniqueIds].every((it) => it != null)) {
      return TaskEither<String, Iterable<QChatRoom>>.left(
          'Please specify either `roomIds` or `uniqueIds`');
    }
    return TaskEither.tryCatch(() async {
      var req = GetRoomInfoRequest(
        roomIds: roomIds?.toList(),
        uniqueIds: uniqueIds?.toList(),
        page: page,
        withParticipants: showParticipants,
        withRemoved: showRemoved,
      );

      return req(dio);
    }, (e, _) => e.toString());
  });
}

class GetRoomInfoRequest extends IApiRequest<Iterable<QChatRoom>> {
  GetRoomInfoRequest({
    this.roomIds,
    this.uniqueIds,
    this.withParticipants,
    this.withRemoved,
    this.page,
  });

  final List<int>? roomIds;
  final List<String>? uniqueIds;
  final bool? withParticipants;
  final bool? withRemoved;
  final int? page;

  @override
  String get url => 'rooms_info';

  @override
  IRequestMethod get method => IRequestMethod.post;

  @override
  Json get body => <String, dynamic>{
        'room_id': roomIds?.map((e) => e.toString()).toList(),
        'room_unique_id': uniqueIds,
        'show_participants': withParticipants,
        'show_removed': withRemoved,
        'page': page,
      };

  @override
  Iterable<QChatRoom> format(Json json) sync* {
    var roomsInfo = (json['results'] as Map?)?['rooms_info'] as List;

    for (var json in roomsInfo.cast<Json>()) {
      yield roomFromJson(json);
    }
  }
}
