part of qiscus_chat_sdk.usecase.room;

class OnRoomMessagesCleared
    with SubscriptionMixin<IRealtimeService, TokenParams, Option<int>> {
  OnRoomMessagesCleared._(this._service);
  factory OnRoomMessagesCleared(IRealtimeService s) =>
      _instance ??= OnRoomMessagesCleared._(s);
  static OnRoomMessagesCleared _instance;
  final IRealtimeService _service;

  @override
  IRealtimeService get repository => _service;

  @override
  Stream<Option<int>> mapStream(_) => repository //
      .subscribeRoomCleared()
      .asyncMap((it) => it.id);

  @override
  Option<String> topic(TokenParams _) {
    return Option.some(TopicBuilder.notification(_.token));
  }
}
