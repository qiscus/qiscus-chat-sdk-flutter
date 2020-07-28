import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/features/message/message.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository.dart';
import 'package:qiscus_chat_sdk/src/features/room/room.dart';
import 'package:test/test.dart';

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
        return right(Tuple2(
            ChatRoom(
              id: some(123),
              extras: some(imap<String, dynamic>(<String, dynamic>{})),
              avatarUrl: some('avatar-url'),
              name: some('name'),
              uniqueId: 'unique-id',
              type: QRoomType.single,
              lastMessage: none(),
              participants: none(),
              sender: none(),
              totalParticipants: some(0),
              unreadCount: some(0),
            ),
            <Message>[]));
      });
    });

    var params = RoomIdParams(123);
    var resp = await useCase.call(params).run();

    resp.fold((l) => fail(l.message), (r) {
      expect(r.value1.id, some<int>(123));
    });

    verify(repo.getRoomWithId(123)).called(1);
    verifyNoMoreInteractions(repo);
  });
}
