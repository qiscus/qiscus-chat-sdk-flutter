part of qiscus_chat_sdk.usecase.message;

class GetMessageListParams {
  const GetMessageListParams(
    this.roomId,
    this.lastMessageId, {
    this.after,
    this.limit,
  });

  final int roomId, lastMessageId, limit;
  final bool after;
}

class GetMessageListUseCase
    extends UseCase<MessageRepository, List<Message>, GetMessageListParams> {
  GetMessageListUseCase(MessageRepository repository) : super(repository);

  @override
  Future<List<Message>> call(GetMessageListParams params) {
    return repository.getMessages(
      params.roomId,
      params.lastMessageId,
      after: params.after,
      limit: params.limit,
    );
  }
}
