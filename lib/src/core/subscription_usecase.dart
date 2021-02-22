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

  Future<void> unsubscribe(Params params) {
    var removeSubscription = () => _subscriptions.remove(params)?.cancel();
    return topic(params)
        .map((it) => repository.unsubscribe(it))
        .map((_) => removeSubscription())
        .getOrElse(() => Future.value(null));
  }

  Stream<Response> subscribe(Params params) async* {
    var subs = () => mapStream(params).listen(_controller.sink.add);
    var ifAbsent = () => Future.value(_subscriptions.putIfAbsent(params, subs))
        .then((_) => _stream);
    var ifEmpty = () => topic(params)
        .map((t) => repository.subscribe(t))
        .map((_) => ifAbsent())
        .getOrElse(() => ifAbsent());

    var stream = await Option.of(_subscriptions[params])
        .map((_) => Future.value(_stream))
        .getOrElse(ifEmpty);

    yield* stream;
  }

  StreamSubscription<Response> listen(
    void Function(Response) onResponse, {
    Function onError,
    bool cancelOnError,
    void Function() onDone,
  }) {
    return _stream.listen(
      onResponse,
      onError: onError,
      cancelOnError: cancelOnError,
      onDone: onDone,
    );
  }
}
