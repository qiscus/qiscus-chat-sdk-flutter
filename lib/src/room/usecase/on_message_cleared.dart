part of qiscus_chat_sdk.usecase.room;

class OnRoomMessagesCleared
    with SubscriptionMixin<IRealtimeService, TokenParams, Option<int>> {
  OnRoomMessagesCleared(this._service);
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
