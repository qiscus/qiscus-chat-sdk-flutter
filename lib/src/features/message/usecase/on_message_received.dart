import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/message/entity.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/service.dart';

@immutable
class RoomIdParams {
  final int roomId;
  const RoomIdParams(this.roomId);
}

class OnMessageReceived
    extends UseCase<RealtimeService, Stream<Message>, RoomIdParams> {
  OnMessageReceived(RealtimeService repository) : super(repository);

  @override
  call(RoomIdParams params) {
    return Task(() async => repository.subscribeMessageReceived())
        .attempt()
        .leftMapToException();
  }
}

class OnMessageRead
    extends UseCase<RealtimeService, Stream<Message>, RoomIdParams> {
  OnMessageRead(RealtimeService repository) : super(repository);

  @override
  call(RoomIdParams params) {
    return Task(() async => repository.subscribeMessageRead(
              roomId: params.roomId,
            ))
        .attempt()
        .leftMapToException()
        .rightMap((res) => res.asyncMap((d) => Message(
              id: int.parse(d.commentId),
              chatRoomId: optionOf(d.roomId),
              uniqueId: optionOf(d.commentUniqueId),
            )));
  }
}

class OnMessageDelivered
    extends UseCase<RealtimeService, Stream<Message>, RoomIdParams> {
  OnMessageDelivered(RealtimeService repository) : super(repository);

  @override
  call(RoomIdParams p) {
    return Task(() async => repository.subscribeMessageDelivered(
              roomId: p.roomId,
            ))
        .attempt()
        .leftMapToException()
        .rightMap((res) => res.asyncMap((d) => Message(
              id: int.parse(d.commentId),
              chatRoomId: optionOf(d.roomId),
              uniqueId: optionOf(d.commentUniqueId),
            )));
  }
}
