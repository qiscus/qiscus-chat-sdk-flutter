part of qiscus_chat_sdk.usecase.room;

class GetTotalUnreadCountUseCase
    extends UseCase<IRoomRepository, int, NoParams> {
  GetTotalUnreadCountUseCase(IRoomRepository repository) : super(repository);

  @override
  Task<Either<QError, int>> call(_) {
    return repository.getTotalUnreadCount();
  }
}
