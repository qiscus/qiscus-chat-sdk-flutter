import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/features/message/message.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/realtime.dart';
import 'package:qiscus_chat_sdk/src/features/room/room.dart';
import 'package:test/test.dart';

class MockRepo extends Mock implements IRoomRepository {}

class MockRealtimeService extends Mock implements IRealtimeService {}

void main() {
  IRoomRepository repo;
  IRealtimeService service;
  ClearRoomMessagesUseCase useCase;
  OnRoomMessagesCleared onRoomMessagesCleared;

  setUpAll(() {
    repo = MockRepo();
    service = MockRealtimeService();
    useCase = ClearRoomMessagesUseCase(repo);
    onRoomMessagesCleared = OnRoomMessagesCleared(service);
  });

  test('ClearRoomMessagesUseCase successfully', () async {
    when(
      repo.clearMessages(uniqueIds: anyNamed('uniqueIds')),
    ).thenAnswer((_) {
      return Task(() async {
        return right(unit);
      });
    });

    var params = ClearRoomMessagesParams(['1234']);

    var resp = await useCase.call(params).run();
    resp.fold((l) => fail(l.message), (r) {});

    verify(repo.clearMessages(uniqueIds: params.uniqueIds)).called(1);
    verifyNoMoreInteractions(repo);
  });

  test('OnRoomMessagesCleared.test', () async {
    var topic = TopicBuilder.notification('some-token');

    when(service.subscribe(any)).thenAnswer((_) {
      return Task(() async => right(null));
    });
    when(service.subscribeRoomCleared()).thenAnswer((_) {
      return Stream.fromIterable([ChatRoom(id: 1.toOption())]);
    });

    var stream =
        await onRoomMessagesCleared.subscribe(TokenParams('some-token')).run();

    stream.listen(expectAsync1((data) {
      expect(data, some(1));
    }, count: 1));

    verify(service.subscribe(topic)).called(1);
    verify(service.subscribeRoomCleared()).called(1);
    verifyNoMoreInteractions(service);
  }, timeout: Timeout(Duration(seconds: 1)));
}
