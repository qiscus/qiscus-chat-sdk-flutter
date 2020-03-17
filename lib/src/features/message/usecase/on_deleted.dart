import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/message/entity.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/service.dart';

class OnMessageDeleted
    extends UseCase<RealtimeService, Stream<Message>, NoParams> {
  OnMessageDeleted(RealtimeService repository) : super(repository);

  @override
  Task<Either<Exception, Stream<Message>>> call(params) {
    return Task(() async {
      return repository.subscribeMessageDeleted();
    }).attempt().leftMapToException().rightMap((res) {
      return res.map((r) {
        return Message(
          id: -1,
          uniqueId: optionOf(r.messageUniqueId),
          chatRoomId: optionOf(r.messageRoomId),
        );
      });
    });
  }
}
