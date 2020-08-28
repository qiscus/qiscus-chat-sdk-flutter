part of qiscus_chat_sdk.usecase.room;

class UserIdParams extends Equatable {
  final String userId;
  final Map<String, dynamic> extras;
  const UserIdParams({
    @required this.userId,
    this.extras,
  });

  get props => [userId];
  get stringify => true;
}

class GetRoomByUserIdUseCase
    extends UseCase<IRoomRepository, ChatRoom, UserIdParams> {
  GetRoomByUserIdUseCase(IRoomRepository repository) : super(repository);

  @override
  Task<Either<QError, ChatRoom>> call(UserIdParams params) {
    return repository.getRoomWithUserId(
      userId: params.userId,
      extras: params.extras,
    );
  }
}
