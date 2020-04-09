import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/message/entity.dart';
import 'package:qiscus_chat_sdk/src/features/message/repository.dart';

class UpdateStatusParams {
  const UpdateStatusParams(this.roomId, this.messageId, this.status);

  final int roomId, messageId;
  final QMessageStatus status;
}

class UpdateStatus
    extends UseCase<MessageRepository, Unit, UpdateStatusParams> {
  UpdateStatus(MessageRepository repository) : super(repository);

  @override
  Task<Either<Exception, Unit>> call(p) {
    if (p.status == QMessageStatus.read) {
      return repository.updateStatus(roomId: p.roomId, readId: p.messageId);
    }
    if (p.status == QMessageStatus.delivered) {
      return repository.updateStatus(
        roomId: p.roomId,
        deliveredId: p.messageId,
      );
    }
    return Task.delay(() => left(Exception(
        'Can not update status for message with status: ${p.status}')));
  }
}
