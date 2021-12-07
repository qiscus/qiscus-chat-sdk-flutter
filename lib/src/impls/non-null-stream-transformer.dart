
import 'dart:async';

StreamTransformer<T?, T> nonNullTransformer<T>() {
  return StreamTransformer.fromBind((stream) async* {
    await for (var data in stream) {
      if (data != null) {
        yield data;
      }
    }
  });
}
