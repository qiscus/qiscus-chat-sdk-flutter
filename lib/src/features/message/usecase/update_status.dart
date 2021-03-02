part of qiscus_chat_sdk.usecase.message;

class UpdateStatusParams {
  const UpdateStatusParams(this.roomId, this.messageId, this.status);

  final int roomId, messageId;
  final QMessageStatus status;
}

class UpdateMessageStatusUseCase
    extends UseCase<MessageRepository, void, UpdateStatusParams> {
  UpdateMessageStatusUseCase(MessageRepository repository) : super(repository);

  @override
  Future<void> call(p) async {
    if (p.status == QMessageStatus.delivered) {
      return repository.updateStatus(
        roomId: p.roomId,
        deliveredId: p.messageId,
      );
    } else if (p.status == QMessageStatus.read) {
      return repository.updateStatus(
        roomId: p.roomId,
        readId: p.messageId,
      );
    } else {
      throw QError(
          'Can not update status for message with status: ${p.status}');
    }
  }
}
