import 'dart:async';

import 'package:async/async.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/realtime.dart';
import 'package:test/test.dart';
import 'package:fake_async/fake_async.dart';

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

void prepareTest(MockRepo mockRepo, MockClass mockClass, {String topic}) {
  when(mockClass.repository).thenReturn(mockRepo);
  when(mockClass.topic(any)).thenAnswer((_) => some(topic));
//    when(mock.mapStream(any)).thenAnswer((_) => Stream.empty());
  when(mockClass.mapStream(any)).thenAnswer(
    (_) => Stream.periodic(Duration(milliseconds: 100), (id) => id),
  );
  when(mockRepo.subscribe(any)).thenAnswer((_) => Future.value(null));
  when(mockRepo.unsubscribe(any)).thenAnswer((_) => Future.value(null));
}

void main() {
  MockClass mockClass;
  MockRepo mockRepo;
  var params = const Params(1);
  const topic = 'my-custom-topic';

  setUp(() {
    mockClass = MockClass();
    mockRepo = MockRepo();
  });

  test('should call repository once', () async {
    prepareTest(mockRepo, mockClass, topic: topic);

    await mockClass.subscribe(params).run();

    verify(mockClass.repository).called(1);
    verify(mockClass.topic(params)).called(1);
    verify(mockClass.mapStream(params)).called(1);
    verify(mockRepo.subscribe(topic)).called(1);
    verifyNoMoreInteractions(mockClass);
    verifyNoMoreInteractions(mockRepo);
  });

  test('subscribing twice should only call repository once', () async {
    prepareTest(mockRepo, mockClass, topic: topic);

    await mockClass.subscribe(params).run();
    await mockClass.subscribe(params).run();

    verify(mockClass.repository).called(1);
    verify(mockClass.topic(params)).called(1);
    verify(mockClass.mapStream(params)).called(1);
    verify(mockRepo.subscribe(topic)).called(1);

    verifyNoMoreInteractions(mockClass);
    verifyNoMoreInteractions(mockRepo);
  });

  test('unsubscribe should call repo unsubscribe', () async {
    prepareTest(mockRepo, mockClass, topic: topic);

    await mockClass.subscribe(params).run();
    await mockClass.unsubscribe(params).run();

    verify(mockRepo.subscribe(topic)).called(1);
    verify(mockRepo.unsubscribe(topic)).called(1);
    verify(mockClass.repository).called(2);
    verify(mockClass.topic(params)).called(2);
    verify(mockClass.mapStream(params)).called(1);

    verifyNoMoreInteractions(mockClass);
    verifyNoMoreInteractions(mockRepo);
  });

  test('unsubscribe should not emit new event', () async {
    fakeAsync((a) {
      prepareTest(mockRepo, mockClass, topic: topic);
      var stream = mockClass.subscribe(params).run();

      var counter = 0;
      var subs = stream.then((s) => s.listen(expectAsync1((data) {
            expect(data, counter++);
          }, count: 6)));
      a.elapse(600.milliseconds);
      subs.then((s) => s.cancel());
      a.elapse(1.s);
    });
  });
}
