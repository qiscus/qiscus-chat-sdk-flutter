part of qiscus_chat_sdk.usecase.room;

class GetRoomInfoUseCase
    extends UseCase<IRoomRepository, List<ChatRoom>, GetRoomInfoParams> {
  GetRoomInfoUseCase(IRoomRepository repository) : super(repository);

  @override
  Task<Either<QError, List<ChatRoom>>> call(p) {
    return repository.getRoomInfo(
      roomIds: p.roomIds,
      uniqueIds: p.uniqueIds,
      withParticipants: p.withParticipants,
      withRemoved: p.withRemoved,
      page: p.page,
    );
  }
}

@sealed
@immutable
class GetRoomInfoParams {
  const GetRoomInfoParams({
    this.roomIds,
    this.uniqueIds,
    this.withParticipants,
    this.withRemoved,
    this.page,
  });
  final List<int> roomIds;
  final List<String> uniqueIds;
  final bool withParticipants;
  final bool withRemoved;
  final int page;
}
