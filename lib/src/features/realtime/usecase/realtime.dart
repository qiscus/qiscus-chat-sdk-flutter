part of qiscus_chat_sdk.usecase.realtime;

class OnConnected with SubscriptionMixin<IRealtimeService, NoParams, void> {
  OnConnected._(this._repo);

  factory OnConnected(IRealtimeService repo) =>
      _instance ??= OnConnected._(repo);
  static OnConnected _instance;
  final IRealtimeService _repo;

  @override
  Stream<void> mapStream(_) => repository.onConnected();

  @override
  IRealtimeService get repository => _repo;

  @override
  Option<String> topic(NoParams p) => none();
}

class OnDisconnected with SubscriptionMixin<IRealtimeService, NoParams, void> {
  OnDisconnected._(this._repo);

  final IRealtimeService _repo;

  factory OnDisconnected(IRealtimeService repo) =>
      _instance ??= OnDisconnected._(repo);
  static OnDisconnected _instance;

  @override
  IRealtimeService get repository => _repo;

  @override
  Stream<void> mapStream(_) => repository.onDisconnected();

  @override
  Option<String> topic(NoParams p) => none();
}

class OnReconnecting with SubscriptionMixin<IRealtimeService, NoParams, void> {
  OnReconnecting._(this._repo);

  final IRealtimeService _repo;

  factory OnReconnecting(IRealtimeService repo) =>
      _instance ??= OnReconnecting._(repo);
  static OnReconnecting _instance;

  @override
  IRealtimeService get repository => _repo;

  @override
  Stream<void> mapStream(_) => repository.onReconnecting();

  @override
  Option<String> topic(NoParams p) => none();
}
