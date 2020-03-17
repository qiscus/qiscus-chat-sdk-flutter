import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository_impl.dart';

abstract class RoomRepository {
  Task<Either<Exception, GetRoomResponse>> getRoomWithUserId(String userId);
  Task<Either<Exception, GetRoomResponse>> getRoomWithId(int roomId);
}
