import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';
import 'package:qiscus_chat_sdk/src/features/room/api.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository.dart';

class RoomRepositoryImpl implements RoomRepository {
  final RoomApi _api;

  const RoomRepositoryImpl(this._api);

  @override
  Task<Either<Exception, GetRoomResponse>> getRoomWithUserId(String userId) {
    return Task(() => _api.chatTarget(ChatTargetRequest([userId])))
        .attempt()
        .leftMapToException()
        .rightMap((res) {
      var json = jsonDecode(res);
      return GetRoomResponse(json['results']['room'] as Map<String, dynamic>);
    });
  }

  @override
  Task<Either<Exception, GetRoomWithMessagesResponse>> getRoomWithId(
      int roomId) {
    return Task(() => _api.getRoomById(roomId))
        .attempt()
        .leftMapToException()
        .rightMap((str) {
      var json = jsonDecode(str);
      var room = json['results']['room'];
      var comments = (json['results']['comments']).cast<Map<String, dynamic>>();
      return GetRoomWithMessagesResponse(room, comments);
    });
  }
}

@immutable
class GetRoomWithMessagesResponse {
  const GetRoomWithMessagesResponse(this.room, this.messages);

  final List<Map<String, dynamic>> messages;
  final Map<String, dynamic> room;
}

@immutable
class GetRoomResponse {
  const GetRoomResponse(this.room);

  final Map<String, dynamic> room;
}
