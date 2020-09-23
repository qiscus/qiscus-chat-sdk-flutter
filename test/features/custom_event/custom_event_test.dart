import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/features/custom_event/custom_event.dart';
import 'package:qiscus_chat_sdk/src/features/message/message.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/realtime.dart';
import 'package:test/test.dart';

class MockService extends Mock implements IRealtimeService {}

void main() {
  IRealtimeService service;
  CustomEventUseCase useCase;

  setUpAll(() {
    service = MockService();
    useCase = CustomEventUseCase(service);
  });

  test('CustomEvent.publish', () async {
    var roomId = 123;
    var payload = <String, dynamic>{
      'key': 'value',
    };
    when(service.publishCustomEvent(
      roomId: anyNamed('roomId'),
      payload: anyNamed('payload'),
    )).thenReturn(right<QError, void>(null));

    var resp = await useCase
        .call(CustomEvent(
          roomId: roomId,
          payload: payload,
        ))
        .run();
    resp.fold((l) => fail(l.message), (r) {});

    verify(service.publishCustomEvent(
      roomId: roomId,
      payload: payload,
    )).called(1);
    verifyNoMoreInteractions(service);
  });

  test('CustomEvent.subscribe', () async {
    var roomId = 123;
    var payload = <String, dynamic>{
      'key': 'value',
    };
    var topic = TopicBuilder.customEvent(roomId);

    when(service.subscribe(any))
        .thenAnswer((_) => Task(() async => right(null)));
    when(service.subscribeCustomEvent(roomId: anyNamed('roomId'))).thenAnswer(
        (_) => Stream.fromIterable(
            [CustomEvent(roomId: roomId, payload: payload)]));

    var stream = await useCase.subscribe(RoomIdParams(roomId)).run();

    stream.listen(expectAsync1((data) {
      expect(data.roomId, roomId);
      expect(data.payload, payload);
    }, count: 1));

    verify(service.subscribe(topic)).called(1);
    // verify(service.subscribeCustomEvent(roomId: roomId)).called(1);
    verifyNoMoreInteractions(service);
  }, timeout: Timeout(Duration(seconds: 10)));
}
