import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository.dart';
import 'package:qiscus_chat_sdk/src/features/room/room.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

class MockRepo extends Mock implements IRoomRepository {}

void main() {
  IRoomRepository repo;
  GetRoomInfoUseCase useCase;

  setUpAll(() {
    repo = MockRepo();
    useCase = GetRoomInfoUseCase(repo);
  });

  test('get room info successfully', () async {
    //
    when(repo.getRoomInfo(
      uniqueIds: anyNamed('uniqueIds'),
      roomIds: anyNamed('roomIds'),
      withParticipants: anyNamed('withParticipants'),
      withRemoved: anyNamed('withRemoved'),
      page: anyNamed('page'),
    )).thenAnswer((_) {
      return Task(() async {
        return right(<ChatRoom>[
          ChatRoom(
            uniqueId: 'unique-id',
            type: QRoomType.single,
            id: some(112),
            name: some('name'),
            unreadCount: some(2),
            avatarUrl: some('avatar-url'),
            totalParticipants: some(12),
            extras: some(imap<String, dynamic>(<String, dynamic>{})),
            participants: none(),
            lastMessage: none(),
            sender: none(),
          ),
        ]);
      });
    });

    var roomIds = [123];
    var resp = await useCase.call(GetRoomInfoParams(roomIds: roomIds)).run();

    resp.fold((l) => fail(l.message), (r) {
      var room = r.single;
      expect(room.id, some(112));
      expect(room.uniqueId, 'unique-id');
    });

    verify(repo.getRoomInfo(roomIds: roomIds)).called(1);
    verifyNoMoreInteractions(repo);
  });
}
