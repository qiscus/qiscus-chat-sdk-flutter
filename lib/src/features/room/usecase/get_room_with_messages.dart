part of qiscus_chat_sdk.usecase.room;

class GetRoomWithMessagesUseCase extends UseCase<IRoomRepository,
    Tuple2<ChatRoom, List<Message>>, RoomIdParams> {
  GetRoomWithMessagesUseCase(IRoomRepository repository) : super(repository);

  @override
  Task<Either<QError, Tuple2<ChatRoom, List<Message>>>> call(params) {
    return repository.getRoomWithId(params.roomId);
  }
}
