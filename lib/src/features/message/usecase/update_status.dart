import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/message/entity.dart';
import 'package:qiscus_chat_sdk/src/features/message/repository.dart';

class UpdateStatusParams {
  const UpdateStatusParams(this.roomId, this.messageId, this.status);

  final int roomId, messageId;
  final QMessageStatus status;
}

class UpdateMessageStatusUseCase
    extends UseCase<MessageRepository, Unit, UpdateStatusParams> {
  UpdateMessageStatusUseCase(MessageRepository repository) : super(repository);

  @override
  Task<Either<QError, Unit>> call(p) {
    switch (p.status) {
      case QMessageStatus.delivered:
        return repository.updateStatus(
            roomId: p.roomId, deliveredId: p.messageId);
      case QMessageStatus.read:
        return repository.updateStatus(roomId: p.roomId, readId: p.messageId);
      default:
        return Task.delay(() => left(QError(
            'Can not update status for message with status: ${p.status}')));
    }
  }
}
