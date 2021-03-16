part of qiscus_chat_sdk.usecase.message;

class UpdateMessageUseCase
    extends UseCase<MessageRepository, Message, MessageParams> {
  UpdateMessageUseCase(MessageRepository repository) : super(repository);

  @override
  Future<Message> call(MessageParams params) {
    return repository.updateMessage(message: params.message);
  }
}
