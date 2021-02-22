part of qiscus_chat_sdk.usecase.message;

class DeleteMessageParams {
  const DeleteMessageParams(
    this.uniqueIds, [
    this.isForEveryone = true,
    this.isHard = true,
  ]);
  final List<String> uniqueIds;
  final bool isForEveryone;
  final bool isHard;
}

class DeleteMessageUseCase
    extends UseCase<MessageRepository, List<Message>, DeleteMessageParams> {
  DeleteMessageUseCase(MessageRepository repository) : super(repository);

  @override
  Future<Either<QError, List<Message>>> call(DeleteMessageParams params) {
    return repository.deleteMessages(
      uniqueIds: params.uniqueIds,
      isForEveryone: params.isForEveryone,
      isHard: params.isHard,
    );
  }
}
