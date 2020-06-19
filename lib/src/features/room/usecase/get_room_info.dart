import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository.dart';
import 'package:qiscus_chat_sdk/src/features/room/room.dart';

class GetRoomInfoUseCase
    extends UseCase<RoomRepository, List<ChatRoom>, GetRoomInfoParams> {
  GetRoomInfoUseCase(RoomRepository repository) : super(repository);

  @override
  Task<Either<QError, List<ChatRoom>>> call(p) {
    return repository.getRoomInfo(
      roomIds: p.roomIds,
      uniqueIds: p.uniqueIds,
      withParticipants: p.withParticipants,
      withRemoved: p.withRemoved,
      page: p.page,
    );
  }
}

@sealed
@immutable
class GetRoomInfoParams {
  const GetRoomInfoParams({
    this.roomIds,
    this.uniqueIds,
    this.withParticipants,
    this.withRemoved,
    this.page,
  });
  final List<int> roomIds;
  final List<String> uniqueIds;
  final bool withParticipants;
  final bool withRemoved;
  final int page;
}
