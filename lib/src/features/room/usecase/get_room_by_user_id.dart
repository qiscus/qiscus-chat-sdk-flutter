import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/room/entity.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository.dart';

class UserIdParams {
  final String userId;
  const UserIdParams(this.userId);
}

class GetRoomByUserId extends UseCase<RoomRepository, ChatRoom, UserIdParams> {
  GetRoomByUserId(RoomRepository repository) : super(repository);

  @override
  Task<Either<Exception, ChatRoom>> call(UserIdParams params) {
    return repository
        .getRoomWithUserId(params.userId)
        .leftMapToException()
        .rightMap((res) => ChatRoom.fromJson(res.room));
  }
}
