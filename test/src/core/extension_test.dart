import 'dart:async';

import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:test/test.dart';

void main() {
  test('StreamTapped', () async {
    var controller = StreamController<int>();

    Stream.fromIterable([1, 2, 3]).tap((item) {
      controller.add(item);
    }).listen((_) {}, onDone: () => controller.close());

    await expectLater(
      controller.stream,
      emitsInOrder([1, 2, 3, emitsDone]),
    );
  });

  test('FlatStream', () async {
    var stream1 = Stream.fromIterable([1, 2, 3]);
    var stream2 = Stream.fromIterable([4, 5, 6]);

    var stream3 = Stream.fromIterable([stream1, stream2]);
    var actual = stream3.flatten();

    await expectLater(
      actual,
      emitsInOrder([1, 2, 3, 4, 5, 6, emitsDone]),
    );
  });

  test('Future tap', () async {
    var future = Future.value(123);
    var completer = Completer();

    future.tap((v) => completer.complete(v)).ignore();

    await expectLater(completer.future, completion(123));
  });

  test('Future chain', () async {
    var future1 = () => Future.value(123);
    var future2 = () => Future.value(456);

    var f = future1().chain(future2());
    await expectLater(f, completion(456));
  });

  test('Duration seconds', () {
    expect(1.seconds, Duration(seconds: 1));
    expect(1.s, Duration(seconds: 1));
  });

  test('Duration milliseconds', () {
    expect(1.milliseconds, Duration(milliseconds: 1));
  });

  test('Stream non null transformer', () async {
    var stream = Stream.fromIterable([1, 2, null, 3, null, null, 4, 5])
        .transform(nonNullTransformer());

    await expectLater(
      stream,
      emitsInOrder([1, 2, 3, 4, 5, emitsDone]),
    );
  });
}
