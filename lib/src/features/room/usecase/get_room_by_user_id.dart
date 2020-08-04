import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/room/entity.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository.dart';

class UserIdParams {
  final String userId;
  const UserIdParams(this.userId);
}

class GetRoomParams extends Equatable {
  final String userId;
  final Map<String, dynamic> extras;

  const GetRoomParams({
    @required this.userId,
    this.extras,
  });

  get props => [userId];
}

class GetRoomByUserIdUseCase
    extends UseCase<IRoomRepository, ChatRoom, UserIdParams> {
  GetRoomByUserIdUseCase(IRoomRepository repository) : super(repository);

  @override
  Task<Either<QError, ChatRoom>> call(UserIdParams params) {
    return repository.getRoomWithUserId(params.userId);
  }
}
