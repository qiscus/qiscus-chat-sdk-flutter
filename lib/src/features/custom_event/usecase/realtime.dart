import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/message/message.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/realtime.dart';

@sealed
class CustomEvent {
  const CustomEvent(this.roomId, this.payload);

  final int roomId;
  final Map<String, dynamic> payload;
}

class CustomEventUseCase extends UseCase<RealtimeService, void, CustomEvent>
    with Subscription<RealtimeService, RoomIdParams, CustomEvent> {
  CustomEventUseCase._(RealtimeService s) : super(s);

  static CustomEventUseCase _instance;

  factory CustomEventUseCase(RealtimeService s) =>
      _instance ??= CustomEventUseCase._(s);

  @override
  Task<Either<QError, void>> call(p) {
    return Task.delay(() => catching<void>(() => repository.publishCustomEvent(
          roomId: p.roomId,
          payload: p.payload,
        )) as Either<QError, void>);
  }

  @override
  Stream<CustomEvent> mapStream(p) => repository
      .subscribeCustomEvent(roomId: p.roomId)
      .asyncMap((response) => CustomEvent(response.roomId, response.payload));

  @override
  Option<String> topic(p) => some(TopicBuilder.customEvent(p.roomId));
}
