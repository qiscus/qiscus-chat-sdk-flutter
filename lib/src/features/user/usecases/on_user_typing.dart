import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/message/usecase/on_message_received.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/service.dart';

@sealed
@immutable
class TypingResponse {
  final String userId;
  final int roomId;
  final bool isTyping;
  const TypingResponse(this.userId, this.roomId, this.isTyping);
}

@sealed
@immutable
class TypingParams {
  final int roomId;
  const TypingParams(this.roomId);
}

class OnUserTyping
    extends UseCase<RealtimeService, Stream<TypingResponse>, RoomIdParams> {
  OnUserTyping(RealtimeService repository) : super(repository);

  @override
  call(params) {
    return Task(() async => repository.subscribeUserTyping(
          roomId: params.roomId,
        )).attempt().leftMapToException().rightMap((res) {
      return res.asyncMap((data) {
        return TypingResponse(data.userId, data.roomId, data.isTyping);
      });
    });
  }
}
