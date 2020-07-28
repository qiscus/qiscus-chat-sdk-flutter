import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/room/entity.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository.dart';

class UserIdParams {
  final String userId;
  const UserIdParams(this.userId);
}

class GetRoomByUserIdUseCase
    extends UseCase<IRoomRepository, ChatRoom, UserIdParams> {
  GetRoomByUserIdUseCase(IRoomRepository repository) : super(repository);

  @override
  Task<Either<QError, ChatRoom>> call(UserIdParams params) {
    return repository.getRoomWithUserId(params.userId);
  }
}
