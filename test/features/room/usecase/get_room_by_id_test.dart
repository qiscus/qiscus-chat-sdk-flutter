import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/features/message/message.dart';
import 'package:qiscus_chat_sdk/src/features/room/room.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:qiscus_chat_sdk/src/features/room/repository.dart';

import 'jsons.dart';

class MockRepo extends Mock implements IRoomRepository {}

void main() {
  //
  IRoomRepository repo;
  GetRoomWithMessagesUseCase useCase;

  setUpAll(() {
    repo = MockRepo();
    useCase = GetRoomWithMessagesUseCase(repo);
  });

  test('get room by id successfully', () async {
    when(repo.getRoomWithId(any)).thenAnswer((_) {
      return Task(() async {
        return right(GetRoomWithMessagesResponse(
          jsonRoomWithIdRoom,
          [jsonRoomWithIdComment],
        ));
      });
    });

    var params = RoomIdParams(123);
    var resp = await useCase.call(params).run();

    resp.fold((l) => fail(l.message), (r) {
      expect(r.value1.id, some<int>(jsonRoomWithIdRoom['id'] as int));
    });

    verify(repo.getRoomWithId(123)).called(1);
    verifyNoMoreInteractions(repo);
  });
}
