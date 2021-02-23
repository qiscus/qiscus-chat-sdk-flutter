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
  Future<Either<Error, void>> call(p) async {
    switch (p.status) {
      case QMessageStatus.delivered:
        return repository.updateStatus(
          roomId: p.roomId,
          deliveredId: p.messageId,
        );
      case QMessageStatus.read:
        return repository.updateStatus(
          roomId: p.roomId,
          readId: p.messageId,
        );
      default:
        return Either.left(
          MError('Can not update status for message with status: ${p.status}'),
        );
    }
  }
}
