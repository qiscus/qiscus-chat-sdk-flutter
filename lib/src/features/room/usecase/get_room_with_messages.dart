import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/message/message.dart';
import 'package:qiscus_chat_sdk/src/features/room/entity.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository.dart';

class GetRoomWithMessagesUseCase extends UseCase<IRoomRepository,
    Tuple2<ChatRoom, List<Message>>, RoomIdParams> {
  GetRoomWithMessagesUseCase(IRoomRepository repository) : super(repository);

  @override
  Task<Either<QError, Tuple2<ChatRoom, List<Message>>>> call(params) {
    return repository.getRoomWithId(params.roomId);
  }
}
