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

  Future<void> ignoreAwaited() async {
    try {
      await this;
    } catch (_) {}
  }
}

extension DurationX on int {
  Duration get seconds => Duration(seconds: this);

  Duration get milliseconds => Duration(milliseconds: this);

  Duration get s => seconds;
}

StreamTransformer<T?, T> nonNullTransformer<T extends Object>() {
  return StreamTransformer.fromBind((stream) async* {
    await for (var data in stream) {
      if (data != null) yield data;
    }
  });
}
