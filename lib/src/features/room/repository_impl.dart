import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/api_request.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/core/utils.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository.dart';

import 'entity.dart';
import 'room_api_request.dart' as req;

class RoomRepositoryImpl implements IRoomRepository {
  final Dio dio;

  const RoomRepositoryImpl({
    @required this.dio,
  });

  @override
  getRoomWithUserId(String userId) {
    return task(() async {
      var request = req.ChatTargetRequest(userId: userId);
      return dio.sendApiRequest(request).then(request.format);
    });
  }

  @override
  getRoomWithId(int roomId) {
    return task(() async {
      var request = req.GetRoomByIdRequest(roomId: roomId);
      return dio.sendApiRequest(request).then(request.format);
    });
  }

  @override
  addParticipant(
    int roomId,
    List<String> participantIds,
  ) {
    return task(() async {
      var request = req.AddParticipantRequest(
        roomId: roomId,
        userIds: participantIds,
      );
      return dio.sendApiRequest(request).then(request.format);
    });
  }

  @override
  removeParticipant(
    int roomId,
    List<String> participantIds,
  ) {
    return task(() async {
      var request = req.RemoveParticipantRequest(
        roomId: roomId,
        userIds: participantIds,
      );
      return dio.sendApiRequest(request).then(request.format);
    });
  }

  @override
  getParticipants(String uniqueId) {
    return task(() async {
      var request = req.GetParticipantRequest(roomUniqueId: uniqueId);
      return dio.sendApiRequest(request).then(request.format);
    });
  }

  @override
  Task<Either<QError, List<ChatRoom>>> getAllRooms({
    bool withParticipants,
    bool withEmptyRoom,
    bool withRemovedRoom,
    int limit,
    int page,
  }) {
    return task(() async {
      var request = req.GetAllRoomRequest(
        withParticipants: withParticipants,
        withEmptyRoom: withEmptyRoom,
        withRemovedRoom: withRemovedRoom,
        limit: limit,
        page: page,
      );
      return dio.sendApiRequest(request).then(request.format);
    });
  }

  @override
  getOrCreateChannel({
    String uniqueId,
    String name,
    String avatarUrl,
    Map<String, dynamic> options,
  }) {
    return task(() async {
      var request = req.GetOrCreateChannelRequest(
        uniqueId: uniqueId,
        name: name,
        avatarUrl: avatarUrl,
        extras: options,
      );
      return dio.sendApiRequest(request).then(request.format);
    });
  }

  @override
  createGroup({
    String name,
    List<String> userIds,
    String avatarUrl,
    Map<String, dynamic> extras,
  }) {
    return task(() async {
      var request = req.CreateGroupRequest(
        name: name,
        userIds: userIds,
        avatarUrl: avatarUrl,
        extras: extras,
      );
      return dio.sendApiRequest(request).then(request.format);
    });
  }

  @override
  clearMessages({
    @required List<String> uniqueIds,
  }) {
    return task(() async {
      var request = req.ClearMessagesRequest(roomUniqueIds: uniqueIds);
      return dio.sendApiRequest(request).then(request.format);
    });
  }

  @override
  getRoomInfo({
    List<int> roomIds,
    List<String> uniqueIds,
    bool withParticipants,
    bool withRemoved,
    int page,
  }) {
    return task(() async {
      var r = req.GetRoomInfoRequest(
        roomIds: roomIds,
        uniqueIds: uniqueIds,
        withParticipants: withParticipants,
        withRemoved: withRemoved,
        page: page,
      );
      return dio.sendApiRequest(r).then(r.format);
    });
  }

  @override
  getTotalUnreadCount() {
    return task(() async {
      var r = req.GetTotalUnreadCountRequest();
      return dio.sendApiRequest(r).then(r.format);
    });
  }

  @override
  Task<Either<QError, ChatRoom>> updateRoom({
    @required int roomId,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  }) {
    return task(() async {
      var r = req.UpdateRoomRequest(
        roomId: roomId.toString(),
        name: name,
        avatarUrl: avatarUrl,
        extras: extras,
      );

      return dio.sendApiRequest(r).then(r.format);
    });
  }
}
