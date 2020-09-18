part of qiscus_chat_sdk.usecase.room;

class GetRoomUseCase extends UseCase<IRoomRepository, ChatRoom, UserIdParams> {
  GetRoomUseCase(IRoomRepository repository) : super(repository);

  @override
  Task<Either<QError, ChatRoom>> call(p) {
    return repository.getRoomWithUserId(
      userId: p.userId,
      extras: p.extras,
    );
  }
}
