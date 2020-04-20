import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/room/entity.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository.dart';

@immutable
class GetRoomParams {
  final String userId;
  const GetRoomParams(this.userId);
}

class GetRoomUseCase extends UseCase<RoomRepository, ChatRoom, GetRoomParams> {
  GetRoomUseCase(RoomRepository repository) : super(repository);

  @override
  Task<Either<Exception, ChatRoom>> call(p) {
    return repository
        .getRoomWithUserId(p.userId)
        .leftMapToException()
        .rightMap((res) => ChatRoom.fromJson(res.room));
  }
}
