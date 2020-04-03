import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository_impl.dart';

import 'api.dart';

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
      List<String> participantIds,);

  Task<Either<Exception, GetParticipantsResponse>> getParticipants(
      String uniqueId,);

  Task<Either<Exception, GetAllRoomsResponse>> getAllRooms({
    bool withParticipants,
    bool withEmptyRoom,
    bool withRemovedRoom,
    int limit,
    int page,
  });
}
