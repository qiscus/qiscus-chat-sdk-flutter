import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/room/entity.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository.dart';

@immutable
class GetAllRoomsParams {
  const GetAllRoomsParams({
    this.withParticipants,
    this.withEmptyRoom,
    this.withRemovedRoom,
    this.limit,
    this.page,
  });

  final bool withParticipants;
  final bool withEmptyRoom;
  final bool withRemovedRoom;
  final int limit, page;
}

class GetAllRoomsUseCase
    extends UseCase<RoomRepository, List<ChatRoom>, GetAllRoomsParams> {
  GetAllRoomsUseCase(RoomRepository repository) : super(repository);

  @override
  Task<Either<QError, List<ChatRoom>>> call(GetAllRoomsParams params) {
    return repository
        .getAllRooms(
          withParticipants: params.withParticipants,
          withRemovedRoom: params.withRemovedRoom,
          withEmptyRoom: params.withEmptyRoom,
          limit: params.limit,
          page: params.page,
        )
        .rightMap((res) => res.rooms);
  }
}
