part of qiscus_chat_sdk.core;

/// A helper mixin for handling subscription based
/// usecase, please ensure [params] implement
/// both == equality method and hashCode
mixin SubscriptionMixin<Service extends IRealtimeService, Params, Response> {
  final _controller = StreamController<Response>();
  final _subscriptions = HashMap<Params, StreamSubscription<Response>>();

  Service get repository;

  Stream<Response> mapStream(Params p);

  Option<String> topic(Params p);

  Stream<Response> get _stream => _controller.stream.asBroadcastStream();

  Task<void> unsubscribe(Params params) {
    var t1 = topic(params).map((_) => repository.unsubscribe(_));
    var t2 = t1.map(
      (_) => _.andThen(Task(() {
        var subscription = _subscriptions[params];
        return subscription?.cancel();
      })),
    );

    return t2.getOrElse(() => Task.delay(() {}));
  }

  Task<Stream<Response>> subscribe(Params params) {
    var listen = () {
      var stream = mapStream(params);
      var subscription = stream.listen((it) => _controller.sink.add(it));
      return subscription;
    };
    var putIfAbsent = () => _subscriptions.putIfAbsent(params, listen);
    var orIfEmpty = () => topic(params)
        .map((topic) => repository.subscribe(topic))
        .map((_) => _.andThen(Task.delay(putIfAbsent)));
    return _subscriptions
        .getValue(params)
        .map((it) => Task.delay(() => it))
        .orElse(orIfEmpty)
        .map((_) => _.map((_) => _stream))
        .getOrElse(() => Task.delay(() => Stream.empty()));
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
