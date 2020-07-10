import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/realtime.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/service.dart';
import 'package:qiscus_chat_sdk/src/features/room/room.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

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

  group('ClearRoomMessagesUseCase', () {
    test('clear room successfully', () async {
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
  });

  group('OnRoomMessagesCleared', () {
    test('subscribe', () async {
      var topic = TopicBuilder.notification('some-token');

      when(service.subscribe(topic)).thenAnswer((_) {
        return Task(() async => right(null));
      });
      when(service.subscribeRoomCleared()).thenAnswer((_) {
        return Stream.value(RoomClearedResponse(room_id: 1));
      });

      var stream = await onRoomMessagesCleared.subscribe(noParams).run();
      await expectLater(stream, emitsInOrder(<int>[1]));
    });
  });
}
