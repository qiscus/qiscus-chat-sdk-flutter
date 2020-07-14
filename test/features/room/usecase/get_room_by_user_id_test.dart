import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository.dart';
import 'package:qiscus_chat_sdk/src/features/room/room.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'jsons.dart';

class MockRepo extends Mock implements IRoomRepository {}

void main() {
  IRoomRepository repo;
  GetRoomByUserIdUseCase useCase;

  setUpAll(() {
    repo = MockRepo();
    useCase = GetRoomByUserIdUseCase(repo);
  });

  test('get room by userId successfully', () async {
    when(repo.getRoomWithUserId(any)).thenReturn(Task(() async {
      return right(GetRoomResponse(jsonRoomWithIdRoom));
    }));

    var params = UserIdParams('user-id');
    var resp = await useCase.call(params).run();

    resp.fold((l) => fail(l.message), (r) {
      expect(r.id, some<int>(jsonRoomWithIdRoom['id'] as int));
    });

    verify(repo.getRoomWithUserId('user-id')).called(1);
    verifyNoMoreInteractions(repo);
  });
}
