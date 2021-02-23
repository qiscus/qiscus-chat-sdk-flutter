part of qiscus_chat_sdk.usecase.message;

class MessageParams {
  final QMessage message;
  const MessageParams(this.message);
}

class SendMessageUseCase
    extends UseCase<MessageRepository, Message, MessageParams> {
  SendMessageUseCase(MessageRepository repository) : super(repository);

  @override
  Future<Either<Error, Message>> call(params) async {
    if (params.message.chatRoomId == null) {
      return Either.left(ArgumentError.notNull('roomId'));
    }
    if (params.message.text == null) {
      return Either.left(ArgumentError.notNull('text'));
    }
    if (params.message.type == null) {
      return Either.left(ArgumentError.notNull('type'));
    }

    return repository.sendMessage(
      params.message.chatRoomId,
      params.message.text,
      type: params.message.type.string,
      uniqueId: params.message.uniqueId,
      extras: params.message.extras,
      payload: params.message.payload,
    );
  }
}
