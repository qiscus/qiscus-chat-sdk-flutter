import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/realtime.dart';
import 'package:qiscus_chat_sdk/src/features/room/room.dart';

@sealed
@immutable
class ClearRoomMessagesParams {
  const ClearRoomMessagesParams(this.uniqueIds);
  final List<String> uniqueIds;
}

class ClearRoomMessagesUseCase
    extends UseCase<RoomRepository, Unit, ClearRoomMessagesParams> {
  ClearRoomMessagesUseCase(RoomRepository repository) : super(repository);

  @override
  Task<Either<QError, Unit>> call(params) {
    return repository.clearMessages(uniqueIds: params.uniqueIds);
  }
}

class OnRoomMessagesCleared with Subscription<RealtimeService, NoParams, int> {
  OnRoomMessagesCleared._(this._service);
  factory OnRoomMessagesCleared(RealtimeService s) =>
      _instance ??= OnRoomMessagesCleared._(s);
  static OnRoomMessagesCleared _instance;
  final RealtimeService _service;

  @override
  RealtimeService get repository => _service;

  @override
  Stream<int> mapStream(_) => repository //
      .subscribeRoomCleared()
      .asyncMap((it) => it.room_id);

  @override
  Option<String> topic(_) => none();
}
