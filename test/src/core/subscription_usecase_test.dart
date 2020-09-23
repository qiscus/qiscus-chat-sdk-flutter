import 'dart:async';

import 'package:async/async.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/realtime.dart';
import 'package:test/test.dart';

class Params with EquatableMixin {
  final int field;

  const Params(this.field);

  @override
  List<Object> get props => [field];

  @override
  bool get stringify => true;
}

class MockRepo extends Mock implements IRealtimeService {}

class MockClass extends Mock with SubscriptionMixin<MockRepo, Params, int> {}

void main() {
  MockClass mock;
  MockRepo repo;
  var params = const Params(1);
  const topic = 'topic';

  setUp(() {
    mock = MockClass();
    repo = MockRepo();

    when(mock.repository).thenReturn(repo);
    when(mock.topic(any)).thenAnswer((_) => some(topic));
//    when(mock.mapStream(any)).thenAnswer((_) => Stream.empty());
    when(mock.mapStream(any)).thenAnswer(
      (_) => Stream.periodic(Duration(milliseconds: 100), (id) => id),
    );
    when(repo.subscribe(any)).thenAnswer((_) => Task(() async => right(null)));
    when(repo.unsubscribe(any))
        .thenAnswer((_) => Task(() async => right(null)));
  });

  test('should call repository once', () async {
    await mock.subscribe(params).run();

    verify(mock.repository).called(1);
    verify(mock.topic(params)).called(1);
    verify(mock.mapStream(params)).called(1);
    verify(repo.subscribe(topic)).called(1);
    verifyNoMoreInteractions(mock);
    verifyNoMoreInteractions(repo);
  });

  test('subscribing twice should only call repository once', () async {
    await mock.subscribe(params).run();
    await mock.subscribe(params).run();

    verify(mock.repository).called(1);
    verify(mock.topic(params)).called(1);
    verify(mock.mapStream(params)).called(1);
    verify(repo.subscribe(topic)).called(1);

    verifyNoMoreInteractions(mock);
    verifyNoMoreInteractions(repo);
  });

  test('unsubscribe should call repo unsubscribe', () async {
    await mock.subscribe(params).run();
    await mock.unsubscribe(params).run();

    verify(repo.subscribe(topic)).called(1);
    verify(repo.unsubscribe(topic)).called(1);
    verify(mock.repository).called(2);
    verify(mock.topic(params)).called(2);
    verify(mock.mapStream(params)).called(1);

    verifyNoMoreInteractions(mock);
    verifyNoMoreInteractions(repo);
  });

  test('unsubscribe should not emit new event', () async {
    var stream = await mock.subscribe(params).run();
    var queue = StreamQueue(stream);

    var timer = Timer(const Duration(milliseconds: 100 * 6), () async {
      // print('cancel the subscription');
      await queue.cancel(immediate: true);
      await mock.unsubscribe(params).run();
    });

    // var counter = 0;
    // stream.listen(expectAsync1((data) {
    //   print('got data: $data | ${timer.isActive}');
    //   expect(data, counter++);
    // }, count: 5, max: 5));

    // Timer(Duration(seconds: 2), () => queue.cancel());
    await expectLater(
      queue,
      emitsInOrder(<StreamMatcher>[
        emits(0),
        emits(1),
        emits(2),
        emits(3),
        emits(4),
        // emitsDone,
      ]),
    );

    timer.cancel();
  }, timeout: Timeout(Duration(seconds: 2)));
}
