part of qiscus_chat_sdk.core;

Future<void> futurify1(void Function(void Function(Exception?)) fn) async {
  final completer = Completer<void>();
  fn((error) {
    if (error != null) return completer.completeError(error);
    return completer.complete();
  });
  return completer.future;
}

Future<T> futurify2<T>(void Function(void Function(T, Exception?)) fn) async {
  final completer = Completer<T>();

  fn((data, error) {
    if (error != null) return completer.completeError(error);
    return completer.complete(data);
  });

  return completer.future;
}

Stream<Out> streamify<Out>(
  SubscriptionFn Function(void Function(Out), void Function() done) fn,
) async* {
  var controller = StreamController<Out>();
  var subscription = fn((data) {
    controller.sink.add(data);
  }, () {
    controller.close();
  });

  controller.onCancel = subscription;
  yield* controller.stream;
}

Option<Map<String, dynamic>> decodeJson(Object? json) {
  return Option.fromNullable(json).flatMap((it) {
    if (it is Map && it.isEmpty) return Option.none();
    if (it is Map && it.isNotEmpty) {
      return Option.of(it as Map<String, dynamic>);
    }
    if (it is String && it.isEmpty) return Option.none();
    if (it is String && it.isNotEmpty) {
      try {
        var opts = jsonDecode(it) as Map<String, dynamic>;
        return Option.of(opts);
      } catch (error) {
        return Option.none();
      }
    }
    return Option.none();
  });
}
