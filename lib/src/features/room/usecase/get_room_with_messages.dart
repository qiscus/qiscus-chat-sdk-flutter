import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/message/message.dart';
import 'package:qiscus_chat_sdk/src/features/room/entity.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository.dart';

class GetRoomWithMessagesUseCase extends UseCase<RoomRepository,
    Tuple2<ChatRoom, List<Message>>, RoomIdParams> {
  GetRoomWithMessagesUseCase(RoomRepository repository) : super(repository);

  @override
  Task<Either<QError, Tuple2<ChatRoom, List<Message>>>> call(params) {
    return repository.getRoomWithId(params.roomId).rightMap(
      (res) {
        var room = ChatRoom.fromJson(res.room);
        var messages = res.messages.map((it) => Message.fromJson(it)).toList();

        room.lastMessage ??= optionOf(messages.last);

        return Tuple2(
          ChatRoom.fromJson(res.room),
          res.messages.map((it) => Message.fromJson(it)).toList(),
        );
      },
    );
  }
}
