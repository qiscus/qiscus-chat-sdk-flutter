part of qiscus_chat_sdk.usecase.message;

class MessageParams {
  final QMessage message;
  const MessageParams(this.message);
}

class SendMessageUseCase
    extends UseCase<MessageRepository, Message, MessageParams> {
  SendMessageUseCase(MessageRepository repository) : super(repository);

  @override
  Task<Either<QError, Message>> call(params) {
    if (params.message.chatRoomId == null) {
      return Task(() async => left(QError('`roomId` can not be null')));
    }
    if (params.message.text == null) {
      return Task(() async => left(QError('`text` can not be null')));
    }
    if (params.message.type == null) {
      return Task(() async => left(QError('`type` can not be null')));
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
