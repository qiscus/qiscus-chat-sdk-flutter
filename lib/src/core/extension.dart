part of qiscus_chat_sdk.core;

extension StreamTapped<T> on Stream<T> {
  Stream<T> tap(void Function(T) tapData) {
    return asyncMap((event) {
      try {
        tapData(event);
        // ignore: avoid_catches_without_on_clauses
      } catch (_) {
        // do nothing
      }
      return event;
    });
  }
}

extension FlatStream<V> on Stream<Stream<V>> {
  Stream<V> flatten() async* {
    await for (var val in this) {
      yield* val;
    }
  }
}

extension FutureX<T> on Future<T> {
  void toCallback1(void Function(QError) callback) {
    then(
      (_) => callback(null),
      onError: (dynamic error) => callback(error as QError),
    );
  }

  void toCallback2(void Function(T, QError) callback) {
    then(
      (value) => callback(value, null),
      onError: (dynamic error) => callback(null, error as QError),
    );
  }

  Future<Either<QError, T>> toEither() async {
    return then(
      (value) => Either.right(value),
      onError: (Object error) => Either.left(QError(error.toString())),
    );
  }

  Future<T> tap(void Function(T) tapFn) {
    return this;
  }

  Future<O> chain<O>(FutureOr<O> future) {
    return then((_) => future);
  }
}

extension DurationX on int {
  Duration get seconds => Duration(seconds: this);

  Duration get milliseconds => Duration(milliseconds: this);

  Duration get s => seconds;
}
