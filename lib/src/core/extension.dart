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
  void toCallback1(void Function(Exception) callback) {
    then(
      (_) => callback(null),
      onError: (dynamic error) => callback(error as Exception),
    );
  }

  void toCallback2(void Function(T, Exception) callback) {
    then(
      (value) => callback(value, null),
      onError: (dynamic error) => callback(null, error as Exception),
    );
  }

  Future<T> tap(void Function(T) tapFn) async {
    try {
      tapFn(await this);
      // ignore: empty_catches
    } catch (_e) {}
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
