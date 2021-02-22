part of qiscus_chat_sdk.usecase.message;

class MessageParams {
  final QMessage message;
  const MessageParams(this.message);
}

class SendMessageUseCase
    extends UseCase<MessageRepository, Message, MessageParams> {
  SendMessageUseCase(MessageRepository repository) : super(repository);

  @override
  Future<Either<QError, Message>> call(params) async {
    if (params.message.chatRoomId == null) {
      return Either.left(QError('`roomId` can not be null'));
    }
    if (params.message.text == null) {
      return Either.left(QError('`text` can not be null'));
    }
    if (params.message.type == null) {
      return Either.left(QError('`type` can not be null'));
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
