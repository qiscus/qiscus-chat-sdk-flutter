import 'package:qiscus_chat_sdk/src/features/room/repository.dart';
import 'package:qiscus_chat_sdk/src/features/room/room.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

import 'jsons.dart';

class MockRepo extends Mock implements IRoomRepository {}

void main() {
  IRoomRepository repo;
  GetRoomUseCase useCase;

  setUpAll(() {
    repo = MockRepo();
    useCase = GetRoomUseCase(repo);
  });

  test('get room successfully', () async {
    var params = GetRoomParams('guest-101');
    when(repo.getRoomWithUserId(any)).thenAnswer((_) {
      return Task(() async {
        return right(GetRoomResponse(jsonRoomWithUserId));
      });
    });

    var resp = await useCase.call(params).run();

    resp.fold((l) => fail(l.message), (r) {
      expect(r.name, some(params.userId));
    });

    verify(repo.getRoomWithUserId(params.userId)).called(1);
    verifyNoMoreInteractions(repo);
  });
}
