import 'dart:async';

Future<void> futurify1(void Function(void Function(Exception)) fn) async {
  final completer = Completer<void>();
  fn((error) {
    if (error != null) return completer.completeError(error);
    return completer.complete();
  });
  return completer.future;
}

Future<T> futurify2<T>(void Function(void Function(T, Exception)) fn) async {
  final completer = Completer<T>();

  fn((data, error) {
    if (error != null) return completer.completeError(error);
    return completer.complete(data);
  });

  return completer.future;
}

typedef Subscription = void Function();

Stream<Out> streamify<Out>(
  Subscription Function(void Function(Out)) fn,
) async* {
  var controller = StreamController<Out>();
  var subscription = fn((data) {
    controller.sink.add(data);
  });

  controller.onCancel = subscription;
  yield* controller.stream;
}
