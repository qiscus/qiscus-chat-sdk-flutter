import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
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
  CustomEventUseCase._(this._service) : super(_service);

  final RealtimeService _service;
  static CustomEventUseCase _instance;

  factory CustomEventUseCase(RealtimeService s) =>
      _instance ??= CustomEventUseCase._(s);

  @override
  Task<Either<Exception, void>> call(p) {
    return Task.delay(() => catching<void>(() => repository.publishCustomEvent(
          roomId: p.roomId,
          payload: p.payload,
        )));
  }

  @override
  Task<Stream<CustomEvent>> subscribe(params) => repository
      .subscribe(TopicBuilder.customEvent(params.roomId))
      .andThen(super.subscribe(params));

  @override
  Stream<CustomEvent> mapStream(p) => repository
      .subscribeCustomEvent(roomId: p.roomId)
      .asyncMap((response) => CustomEvent(response.roomId, response.payload));
}
