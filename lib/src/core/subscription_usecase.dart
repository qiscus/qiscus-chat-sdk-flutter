part of qiscus_chat_sdk.core;

/// A helper mixin for handling subscription based
/// usecase, please ensure [params] implement
/// both == equality method and hashCode
mixin SubscriptionMixin<Service extends IRealtimeService,
    Params extends EquatableMixin, Response> {
  final _controller = StreamController<Response>.broadcast();
  final _subscriptions = HashMap<Params, StreamSubscription<Response>>();

  Service get repository;
  Stream<Response> mapStream(Params p);
  Option<String> topic(Params p);
  Stream<Response> get _stream => _controller.stream;

  Future<void> clear() async {
    _subscriptions.values.forEach((it) => it.cancel());
    _subscriptions.clear();
  }

  Task<void> unsubscribe(Params params) {
    var removeSubscription =
        Task(() => _subscriptions.remove(params)?.cancel());
    return topic(params)
        .map((it) => Task(() => repository.unsubscribe(it)))
        .map((it) => it.andThen(removeSubscription))
        .getOrElse(() => Task(() async {}));
  }

  Task<Stream<Response>> subscribe(Params params) {
    var listen = () => mapStream(params).listen(_controller.sink.add);

    var putIfAbsent =
        Task(() async => _subscriptions.putIfAbsent(params, listen))
            .andThen(Task(() async => _stream));

    var orIfEmpty = () => topic(params)
        .map((topic) => repository.subscribe(topic))
        .map((_) => putIfAbsent)
        .getOrElse(() => putIfAbsent);

    return _subscriptions
        .getValue(params)
        .map((_) => Task(() async => _stream))
        .getOrElse(orIfEmpty);
  }

  Task<StreamSubscription<Response>> listen(
    void Function(Response) onResponse, {
    Function onError,
    bool cancelOnError,
    void Function() onDone,
  }) {
    return Task(() async {
      return _stream.listen(
        onResponse,
        onError: onError,
        cancelOnError: cancelOnError,
        onDone: onDone,
      );
    });
  }
}

extension HashMapX<Key, Value> on HashMap<Key, Value> {
  Option<Value> getValue(Key key) {
    return optionOf(this[key]);
  }
}
