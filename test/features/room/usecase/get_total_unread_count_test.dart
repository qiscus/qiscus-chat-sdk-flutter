import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository.dart';
import 'package:qiscus_chat_sdk/src/features/room/room.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

class MockRepo extends Mock implements IRoomRepository {}

void main() {
  IRoomRepository repo;
  GetTotalUnreadCountUseCase useCase;

  setUpAll(() {
    repo = MockRepo();
    useCase = GetTotalUnreadCountUseCase(repo);
  });

  test('get total unread count successfully', () async {
    when(repo.getTotalUnreadCount()).thenReturn(Task.delay(() => right(1)));

    var resp = await useCase.call(noParams).run();

    resp.fold((l) => fail(l.message), (r) {
      expect(r, 1);
    });

    verify(repo.getTotalUnreadCount()).called(1);
    verifyNoMoreInteractions(repo);
  });
}
