import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';
import 'package:qiscus_chat_sdk/src/features/room/api.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/participant.dart';

import 'entity.dart';

class RoomRepositoryImpl implements RoomRepository {
  final RoomApi _api;

  const RoomRepositoryImpl(this._api);

  @override
  Task<Either<Exception, GetRoomResponse>> getRoomWithUserId(String userId) {
    return Task(() => _api.chatTarget(ChatTargetRequest([userId])))
        .attempt()
        .leftMapToException()
        .rightMap((res) {
      var json = jsonDecode(res) as Map<String, dynamic>;
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
      var json = jsonDecode(str) as Map<String, dynamic>;
      var room = json['results']['room'] as Map<String, dynamic>;
      var comments = (json['results']['comments'] as List) //
          .cast<Map<String, dynamic>>();
      return GetRoomWithMessagesResponse(room, comments);
    });
  }

  @override
  Task<Either<Exception, AddParticipantResponse>> addParticipant(
    int roomId,
    List<String> participantIds,
  ) {
    return Task(() =>
            _api.addParticipant(ParticipantRequest(roomId.toString(), participantIds)))
        .attempt()
        .leftMapToException()
        .rightMap((str) {
      var json = jsonDecode(str) as Map<String, dynamic>;
      var _participants = (json['results']['participants_added'] as List)
          .cast<Map<String, dynamic>>();
      var participants = _participants //
          .map((json) => Participant.fromJson(json))
          .toList();
      return AddParticipantResponse(roomId, participants);
    });
  }

  @override
  Task<Either<Exception, RemoveParticipantResponse>> removeParticipant(
      int roomId, List<String> participantIds) {
    return Task(() =>
            _api.removeParticipant(ParticipantRequest(roomId.toString(), participantIds)))
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
      var json = jsonDecode(str) as Map<String, dynamic>;
      var participants_ = (json['results']['participants'] as List)
          .cast<Map<String, dynamic>>();
      var participants = participants_ //
          .map((json) => Participant.fromJson(json))
          .toList();
      return GetParticipantsResponse(uniqueId, participants);
    });
  }

  @override
  Task<Either<Exception, GetAllRoomsResponse>> getAllRooms({
    bool withParticipants,
    bool withEmptyRoom,
    bool withRemovedRoom,
    int limit,
    int page,
  }) {
    return Task(() => _api.getAllRooms(GetAllRoomsRequest(
          withEmptyRoom: withEmptyRoom,
          withParticipants: withParticipants,
          withRemovedRoom: withParticipants,
          limit: limit,
          page: page,
        ))).attempt().leftMapToException().rightMap((str) {
      var json = jsonDecode(str) as Map<String, dynamic>;
      var rooms_ = (json['results']['rooms_info'] as List) //
          .cast<Map<String, dynamic>>();
      var rooms = rooms_.map((json) => ChatRoom.fromJson(json)).toList();
      return GetAllRoomsResponse(rooms);
    });
  }

  @override
  Task<Either<Exception, ChatRoom>> getOrCreateChannel({
    String uniqueId,
    String name,
    String avatarUrl,
    Map<String, dynamic> options,
  }) {
    return Task(() => _api.getOrCreateChannel(GetOrCreateChannelRequest(
          uniqueId: uniqueId,
          name: name,
          avatarUrl: avatarUrl,
          options: options,
        ))).attempt().leftMapToException().rightMap((res) {
      var json = jsonDecode(res) as Map<String, dynamic>;
      return ChatRoom.fromJson(json['results']['room'] as Map<String, dynamic>);
    });
  }

  @override
  Task<Either<Exception, ChatRoom>> createGroup({
    String name,
    List<String> userIds,
    String avatarUrl,
    Map<String, dynamic> extras,
  }) {
    return Task(() => _api.createGroup(CreateGroupRequest(
          name: name,
          userIds: userIds,
          avatarUrl: avatarUrl,
          extras: extras,
        ))).attempt().leftMapToException().rightMap((resp) {
      var json = jsonDecode(resp) as Map<String, dynamic>;
      return ChatRoom.fromJson(json['results']['room'] as Map<String, dynamic>);
    });
  }

  @override
  Task<Either<Exception, Unit>> clearMessages({
    @required List<String> uniqueIds,
  }) {
    return Task(() => _api.clearMessages(uniqueIds))
        .attempt()
        .leftMapToException()
        .rightMap((_) => unit);
  }

  @override
  Task<Either<Exception, List<ChatRoom>>> getRoomInfo({
    List<int> roomIds,
    List<String> uniqueIds,
    bool withParticipants,
    bool withRemoved,
    int page,
  }) {
    return Task(() => _api.getRoomInfo(GetRoomInfoRequest(
          roomIds: roomIds.map((it) => it.toString()).toList(),
          uniqueIds: uniqueIds,
          withParticipants: withParticipants,
          withRemoved: withRemoved,
          page: page,
        ))).attempt().leftMapToException().rightMap((str) {
      var json = jsonDecode(str) as Map<String, dynamic>;
      var roomsInfo = json['results']['rooms_info'] as List;
      return roomsInfo
          .cast<Map<String, dynamic>>()
          .map((json) => ChatRoom.fromJson(json))
          .toList();
    });
  }

  @override
  Task<Either<Exception, int>> getTotalUnreadCount() {
    return Task(() => _api.getTotalUnreadCount())
        .attempt()
        .leftMapToException()
        .rightMap((str) {
      var json = jsonDecode(str) as Map<String, dynamic>;
      return json['results']['total_unread_count'] as int;
    });
  }

  @override
  Task<Either<Exception, ChatRoom>> updateRoom({
    @required int roomId,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  }) {
    return Task(() => _api.updateRoom(UpdateRoomRequest(
          roomId: roomId.toString(),
          name: name,
          avatarUrl: avatarUrl,
          extras: extras,
        ))).attempt().leftMapToException().rightMap((str) {
      var json = jsonDecode(str) as Map<String, dynamic>;
      return ChatRoom.fromJson(json['results']['room'] as Map<String, dynamic>);
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
