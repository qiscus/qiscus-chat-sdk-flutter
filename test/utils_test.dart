import 'package:qiscus_chat_sdk/src/core/utils.dart';
import 'package:test/test.dart';

class Dummy {
  void onFuture(void Function(int, Exception) callback) {
    onFuture$()
        .then((data) => callback(data, null))
        .catchError((dynamic error) => callback(null, error as Exception));
  }

  void Function() onStream(void Function(int) callback) {
    var subscription = onStream$().listen((data) {
      callback(data);
    });

    return () => subscription.cancel();
  }

  Future<int> onFuture$() async {
    return Future.delayed(const Duration(milliseconds: 1), () => 1);
  }

  Stream<int> onStream$() async* {
    var stream = Stream.periodic(const Duration(milliseconds: 1), (id) => id);
    yield* stream;
  }
}

void main() {
  Dummy dummy;
  setUpAll(() {
    dummy = Dummy();
  });
  test('futurify1', () async {
    var future1 = futurify1((cb) => dummy.onFuture((_, e) => cb(e)));
  });

  test('futurify2', () async {
    var future2 = futurify2<int>((cb) => dummy.onFuture((d, e) => cb(d, e)));
  });
}
