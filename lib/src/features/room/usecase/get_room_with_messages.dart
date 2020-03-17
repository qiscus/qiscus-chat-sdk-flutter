import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/message/usecase/on_message_received.dart';
import 'package:qiscus_chat_sdk/src/features/room/entity.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository.dart';

class GetRoomWithMessages
    extends UseCase<RoomRepository, ChatRoom, RoomIdParams> {
  GetRoomWithMessages(RoomRepository repository) : super(repository);

  @override
  Task<Either<Exception, ChatRoom>> call(params) {
    return repository
        .getRoomWithId(params.roomId)
        .rightMap((res) => ChatRoom.fromJson(res.room));
  }
}
