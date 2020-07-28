import 'package:qiscus_chat_sdk/src/features/room/repository.dart';
import 'package:qiscus_chat_sdk/src/features/room/room.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

class MockRepo extends Mock implements IRoomRepository {}

void main() {
  IRoomRepository repo;
  GetAllRoomsUseCase useCase;

  setUpAll(() {
    repo = MockRepo();
    useCase = GetAllRoomsUseCase(repo);
  });

  test('get all room successfully', () async {
    when(repo.getAllRooms(
      withParticipants: anyNamed('withParticipants'),
      withEmptyRoom: anyNamed('withEmptyRoom'),
      withRemovedRoom: anyNamed('withRemovedRoom'),
      limit: anyNamed('limit'),
      page: anyNamed('page'),
    )).thenReturn(Task(() async {
      return right(<ChatRoom>[
        ChatRoom(
          uniqueId: 'unique-id',
          type: QRoomType.single,
          id: some(123),
          name: some('name'),
          unreadCount: some(12),
          avatarUrl: some('avatar'),
          totalParticipants: none(),
          extras: none(),
          participants: none(),
          lastMessage: none(),
          sender: none(),
        ),
      ]);
    }));

    var params = GetAllRoomsParams();
    var resp = await useCase.call(params).run();

    resp.fold((l) => fail(l.message), (r) {
      var room = r.first;
      expect(room.id, some(123));
    });

    verify(repo.getAllRooms()).called(1);
    verifyNoMoreInteractions(repo);
  });
}
