
import 'dart:async';

StreamTransformer<T?, T> nonNullTransformer<T>() {
  return StreamTransformer.fromHandlers(handleData: (data, sink) {
    if (data != null) {
      sink.add(data);
    }
  });
}
