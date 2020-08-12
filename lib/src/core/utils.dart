import 'dart:async';

import 'package:dartz/dartz.dart';

import '../typedefs.dart';
import 'errors.dart';
import 'extension.dart';

Future<void> futurify1(void Function(void Function(QError)) fn) async {
  final completer = Completer<void>();
  fn((error) {
    if (error != null) return completer.completeError(error);
    return completer.complete();
  });
  return completer.future;
}

Future<T> futurify2<T>(void Function(void Function(T, QError)) fn) async {
  final completer = Completer<T>();

  fn((data, error) {
    if (error != null) return completer.completeError(error);
    return completer.complete(data);
  });

  return completer.future;
}

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

Task<Either<QError, T>> task<T>(Future<T> Function() cb) {
  return Task(cb).attempt().leftMapToQError();
}
