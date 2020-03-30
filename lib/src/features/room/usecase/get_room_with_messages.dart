import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/message/message.dart';
import 'package:qiscus_chat_sdk/src/features/room/entity.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository.dart';

class GetRoomWithMessages extends UseCase<RoomRepository,
    Tuple2<ChatRoom, List<Message>>, RoomIdParams> {
  GetRoomWithMessages(RoomRepository repository) : super(repository);

  @override
  Task<Either<Exception, Tuple2<ChatRoom, List<Message>>>> call(params) {
    return repository.getRoomWithId(params.roomId).rightMap((res) => Tuple2(
          ChatRoom.fromJson(res.room),
          res.messages.map((it) => Message.fromJson(it)).toList(),
        ));
  }
}
