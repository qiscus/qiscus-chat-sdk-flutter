part of qiscus_chat_sdk.core;

/// A helper mixin for handling subscription based
/// usecase, please ensure [params] implement
/// both == equality method and hashCode
mixin SubscriptionMixin<Repository extends IRealtimeService, Params, Response> {
  final _controller = StreamController<Response>.broadcast();
  final _subscriptions = HashMap<Params, StreamSubscription<Response>>();

  Repository get repository;
  Stream<Response> mapStream(Params p);
  Option<String> topic(Params p);

  Stream<Response> get stream => _controller.stream;

  Task<void> unsubscribe(Params params) {
    return Task.delay(() => topic(params))
        .bind((topic) => topic.fold(
              () => Task.delay(() {}),
              (topic) => repository.unsubscribe(topic),
            ))
        .andThen(Task.delay(() => _subscriptions.remove(params)?.cancel()));
  }

  Task<Stream<Response>> subscribe(Params params) {
    return _subscriptions //
        .getValue(params)
        .fold(
          () => Task.delay(() => topic(params))
              .bind((topic) => topic.fold(
                    () => Task.delay(() {}),
                    (topic) => repository.subscribe(topic),
                  ))
              .andThen(Task.delay(() => _subscriptions.putIfAbsent(
                    params,
                    () => mapStream(params).listen((data) {
                      _controller.sink.add(data);
                    }),
                  )))
              .andThen(Task.delay(() => _controller.stream)),
          (_) => Task.delay(() => _controller.stream),
        );
  }

  Task<StreamSubscription<Response>> listen(
    void Function(Response) onResponse, {
    Function onError,
    bool cancelOnError,
    void Function() onDone,
  }) {
    return Task(() async {
      return _controller.stream.listen(
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
