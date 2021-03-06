import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:test/test.dart';

class Dummy {
  void onFuture(void Function(int, Exception) callback) {
    onFuture$().then((data) => callback(data, null)).catchError(
        (dynamic error) => callback(null, Exception(error.toString())));
  }

  void onFutureE(void Function(int, Exception) callback) {
    Future<int>.error(Exception('some error')).catchError((Exception e) {
      callback(null, e);
      return 0;
    });
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
  test('futurify1 success', () async {
    var future1 = () => futurify1((cb) => dummy.onFuture((_, e) => cb(e)));

    expect(() => future1(), returnsNormally);
  });

  test('futurify1 failure', () async {
    var future1 = () => futurify1((cb) => dummy.onFutureE((_, e) => cb(e)));

    expect(
        () => future1(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'should throw',
          'some error',
        )));
  }, skip: true);

  test('futurify2 success', () async {
    var future2 = () => futurify2<int>(
          (cb) => dummy.onFuture((d, e) => cb(d, e)),
        );

    expect(() => future2(), returnsNormally);
  });

  test('futurify2 failure', () async {
    var future2 = () => futurify2<int>(
          (cb) => dummy.onFutureE((d, e) => cb(d, e)),
        );

    expect(
        () => future2(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'should throw',
          'some error',
        )));
  }, skip: true);
}
