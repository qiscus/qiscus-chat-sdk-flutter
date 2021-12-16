part of qiscus_chat_sdk.usecase.realtime;

class OnConnected with SubscriptionMixin<IRealtimeService, NoParams, void> {
  OnConnected(this._repo);
  final IRealtimeService _repo;

  @override
  Stream<void> mapStream(_) => repository.onConnected();

  @override
  IRealtimeService get repository => _repo;

  @override
  Option<String> topic(NoParams p) => Option.none();
}

class OnDisconnected with SubscriptionMixin<IRealtimeService, NoParams, void> {
  OnDisconnected(this._repo);
  final IRealtimeService _repo;

  @override
  IRealtimeService get repository => _repo;

  @override
  Stream<void> mapStream(_) => repository.onDisconnected();

  @override
  Option<String> topic(NoParams p) => Option.none();
}

class OnReconnecting with SubscriptionMixin<IRealtimeService, NoParams, void> {
  OnReconnecting(this._repo);

  final IRealtimeService _repo;

  @override
  IRealtimeService get repository => _repo;

  @override
  Stream<void> mapStream(_) => repository.onReconnecting();

  @override
  Option<String> topic(NoParams p) => Option.none();
}
