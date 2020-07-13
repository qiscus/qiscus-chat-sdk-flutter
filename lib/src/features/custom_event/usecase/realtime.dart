import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/message/message.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/realtime.dart';

@sealed
class CustomEvent extends Equatable {
  const CustomEvent(this.roomId, this.payload);

  final int roomId;
  final Map<String, dynamic> payload;

  @override
  List<Object> get props => [roomId, payload];
}

class CustomEventUseCase extends UseCase<IRealtimeService, void, CustomEvent>
    with Subscription<IRealtimeService, RoomIdParams, CustomEvent> {
  CustomEventUseCase._(IRealtimeService s) : super(s);

  static CustomEventUseCase _instance;

  factory CustomEventUseCase(IRealtimeService s) =>
      _instance ??= CustomEventUseCase._(s);

  @override
  Task<Either<QError, void>> call(p) {
    return Task.delay<Either<QError, void>>(() {
      return repository.publishCustomEvent(
        roomId: p.roomId,
        payload: p.payload,
      );
    });
  }

  @override
  Stream<CustomEvent> mapStream(p) => repository
      .subscribeCustomEvent(roomId: p.roomId)
      .asyncMap((response) => CustomEvent(response.roomId, response.payload));

  @override
  Option<String> topic(p) => some(TopicBuilder.customEvent(p.roomId));
}
