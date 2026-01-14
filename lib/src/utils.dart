import 'dart:async';

import 'package:fpdart/fpdart.dart';

import '../qiscus_chat_sdk.dart';
import 'impls/mqtt-impls.dart';

extension TaskEitherX<L extends QError, R> on TaskEither<L, R> {
  Future<R> runOrThrow() async {
    return run().then((it) => it.toThrow());
  }

  TaskEither<L, R> tap(void Function(R) onRight) {
    return map((v) {
      try {
        onRight(v);
      } catch (_) {}
      return v;
    });
  }
}

extension EitherX<L extends QError, R> on Either<L, R> {
  R toThrow() {
    return match(
      (l) => throw l,
      (r) => r,
    );
  }
}

typedef StateTransformer<T>
    = StreamTransformer<QMqttMessage, State<Iterable<T>, T>>;
