part of qiscus_chat_sdk.usecase.room;

@immutable
class GetAllRoomsParams {
  const GetAllRoomsParams({
    this.withParticipants,
    this.withEmptyRoom,
    this.withRemovedRoom,
    this.limit,
    this.page,
  });

  final bool withParticipants;
  final bool withEmptyRoom;
  final bool withRemovedRoom;
  final int limit, page;
}

class GetAllRoomsUseCase
    extends UseCase<IRoomRepository, List<ChatRoom>, GetAllRoomsParams> {
  GetAllRoomsUseCase(IRoomRepository repository) : super(repository);

  @override
  Task<Either<QError, List<ChatRoom>>> call(GetAllRoomsParams params) {
    return repository.getAllRooms(
      withParticipants: params.withParticipants,
      withRemovedRoom: params.withRemovedRoom,
      withEmptyRoom: params.withEmptyRoom,
      limit: params.limit,
      page: params.page,
    );
  }
}
