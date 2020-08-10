import 'package:dartz/dartz.dart';

import '../../../core/core.dart';
import '../../../core/usecases.dart';
import '../../message/message.dart';
import '../../realtime/realtime.dart';
import '../../realtime/topic_builder.dart';
import '../entity.dart';

class CustomEventUseCase extends UseCase<IRealtimeService, void, CustomEvent>
    with Subscription<IRealtimeService, RoomIdParams, CustomEvent> {
  CustomEventUseCase._(IRealtimeService s) : super(s);

  static CustomEventUseCase _instance;

  factory CustomEventUseCase(IRealtimeService s) =>
      _instance ??= CustomEventUseCase._(s);

  @override
  Task<Either<QError, void>> call(CustomEvent p) {
    return Task.delay<Either<QError, void>>(() {
      return repository.publishCustomEvent(
        roomId: p.roomId,
        payload: p.payload,
      );
    });
  }

  @override
  Stream<CustomEvent> mapStream(RoomIdParams p) {
    return repository.subscribeCustomEvent(roomId: p.roomId);
  }

  @override
  Option<String> topic(RoomIdParams p) =>
      some(TopicBuilder.customEvent(p.roomId));
}
