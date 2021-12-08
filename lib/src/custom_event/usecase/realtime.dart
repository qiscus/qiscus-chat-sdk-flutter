part of qiscus_chat_sdk.usecase.custom_event;

class CustomEventUseCase extends UseCase<IRealtimeService, void, CustomEvent>
    with SubscriptionMixin<IRealtimeService, RoomIdParams, CustomEvent> {
  CustomEventUseCase._(IRealtimeService s) : super(s);

  static CustomEventUseCase? _instance;

  factory CustomEventUseCase(IRealtimeService s) =>
      _instance ??= CustomEventUseCase._(s);

  @override
  Future<void> call(CustomEvent p) {
    return repository.publishCustomEvent(roomId: p.roomId, payload: p.payload);
  }

  @override
  Stream<CustomEvent> mapStream(RoomIdParams p) async* {
    yield* repository.subscribeCustomEvent(roomId: p.roomId);
  }

  @override
  Option<String> topic(RoomIdParams p) {
    return Option.some(TopicBuilder.customEvent(p.roomId));
  }
}
