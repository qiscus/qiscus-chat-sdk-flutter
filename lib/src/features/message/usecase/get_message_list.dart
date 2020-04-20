import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/message/entity.dart';
import 'package:qiscus_chat_sdk/src/features/message/repository.dart';

class GetMessageListParams {
  const GetMessageListParams(
    this.roomId,
    this.lastMessageId, {
    this.after,
    this.limit,
  });

  final int roomId, lastMessageId, limit;
  final bool after;
}

class GetMessageListUseCase
    extends UseCase<MessageRepository, List<Message>, GetMessageListParams> {
  GetMessageListUseCase(MessageRepository repository) : super(repository);

  @override
  Task<Either<Exception, List<Message>>> call(GetMessageListParams params) {
    return repository
        .getMessages(
          params.roomId,
          params.lastMessageId,
          after: params.after,
          limit: params.limit,
        )
        .rightMap(
          (res) => res.messages //
              .map((json) => Message.fromJson(json))
              .toList(),
        );
  }
}
