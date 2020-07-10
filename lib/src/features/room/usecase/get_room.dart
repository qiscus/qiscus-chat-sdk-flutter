import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/room/entity.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository.dart';

@immutable
class GetRoomParams {
  final String userId;
  const GetRoomParams(this.userId);
}

class GetRoomUseCase extends UseCase<IRoomRepository, ChatRoom, GetRoomParams> {
  GetRoomUseCase(IRoomRepository repository) : super(repository);

  @override
  Task<Either<QError, ChatRoom>> call(p) {
    return repository
        .getRoomWithUserId(p.userId)
        .leftMapToQError()
        .rightMap((res) => ChatRoom.fromJson(res.room));
  }
}
