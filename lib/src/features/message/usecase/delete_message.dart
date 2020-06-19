import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/features/message/message.dart';

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
  Task<Either<QError, List<Message>>> call(DeleteMessageParams params) {
    return repository.deleteMessages(
      uniqueIds: params.uniqueIds,
      isForEveryone: params.isForEveryone,
      isHard: params.isHard,
    );
  }
}
