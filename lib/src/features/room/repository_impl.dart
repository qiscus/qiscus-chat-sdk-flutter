import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';
import 'package:qiscus_chat_sdk/src/features/room/api.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/participant.dart';

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

  @override
  Task<Either<Exception, AddParticipantResponse>> addParticipant(
    int roomId,
    List<String> participantIds,
  ) {
    return Task(() =>
            _api.addParticipant(ParticipantRequest(roomId, participantIds)))
        .attempt()
        .leftMapToException()
        .rightMap((str) {
      var json = jsonDecode(str) as Map<String, dynamic>;
      var _participants = (json['results']['participants_added'] as List)
          .cast<Map<String, dynamic>>();
      var participants = _participants //
          .map((json) => Participant.fromJson(json));
      return AddParticipantResponse(roomId, participants);
    });
  }

  @override
  Task<Either<Exception, RemoveParticipantResponse>> removeParticipant(
      int roomId, List<String> participantIds) {
    return Task(() =>
            _api.removeParticipant(ParticipantRequest(roomId, participantIds)))
        .attempt()
        .leftMapToException()
        .rightMap((str) {
      var json = jsonDecode(str) as Map<String, dynamic>;
      var ids = (json['results']['participants_removed'] as List) //
          .cast<String>();
      return RemoveParticipantResponse(roomId, ids);
    });
  }

  @override
  Task<Either<Exception, GetParticipantsResponse>> getParticipants(
      String uniqueId) {
    return Task(() => _api.getParticipants(GetParticipantsRequest(uniqueId)))
        .attempt()
        .leftMapToException()
        .rightMap((str) {
      var json = jsonDecode(str);
      var participants_ = (json['results']['participants'] as List)
          .cast<Map<String, dynamic>>();
      var participants = participants_ //
          .map((json) => Participant.fromJson(json));
      return GetParticipantsResponse(uniqueId, participants);
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
