import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository_impl.dart';

import 'api.dart';
import 'entity.dart';

abstract class RoomRepository {
  Task<Either<Exception, GetRoomResponse>> getRoomWithUserId(String userId);

  Task<Either<Exception, GetRoomWithMessagesResponse>> getRoomWithId(
      int roomId);

  Task<Either<Exception, AddParticipantResponse>> addParticipant(
    int roomId,
    List<String> participantIds,
  );

  Task<Either<Exception, RemoveParticipantResponse>> removeParticipant(
    int roomId,
    List<String> participantIds,
  );

  Task<Either<Exception, GetParticipantsResponse>> getParticipants(
    String uniqueId,
  );

  Task<Either<Exception, GetAllRoomsResponse>> getAllRooms({
    bool withParticipants,
    bool withEmptyRoom,
    bool withRemovedRoom,
    int limit,
    int page,
  });

  Task<Either<Exception, ChatRoom>> getOrCreateChannel({
    @required String uniqueId,
    String name,
    String avatarUrl,
    Map<String, dynamic> options,
  });

  Task<Either<Exception, ChatRoom>> createGroup({
    @required String name,
    @required List<String> userIds,
    String avatarUrl,
    Map<String, dynamic> extras,
  });

  Task<Either<Exception, Unit>> clearMessages({
    @required List<String> uniqueIds,
  });

  Task<Either<Exception, List<ChatRoom>>> getRoomInfo({
    List<int> roomIds,
    List<String> uniqueIds,
    bool withParticipants,
    bool withRemoved,
    int page,
  });

  Task<Either<Exception, int>> getTotalUnreadCount();

  Task<Either<Exception, ChatRoom>> updateRoom({
    @required int roomId,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  });
}
