import 'package:qiscus_chat_sdk/src/features/room/repository.dart';
import 'package:qiscus_chat_sdk/src/features/room/room.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

class MockRepo extends Mock implements IRoomRepository {}

void main() {
  IRoomRepository repo;
  GetRoomUseCase useCase;

  setUpAll(() {
    repo = MockRepo();
    useCase = GetRoomUseCase(repo);
  });

  test('get room successfully', () async {
    var params = UserIdParams(userId: 'guest-101');
    when(repo.getRoomWithUserId(
      userId: anyNamed('userId'),
      extras: anyNamed('extras'),
    )).thenAnswer((_) {
      return Task(() async {
        return right(ChatRoom(
          id: some(123),
          extras: some(imap<String, dynamic>(<String, dynamic>{})),
          avatarUrl: some('avatar-url'),
          name: some('guest-101'),
          uniqueId: 'unique-id'.toOption(),
          type: QRoomType.single.toOption(),
          lastMessage: none(),
          participants: none(),
          sender: none(),
          totalParticipants: some(0),
          unreadCount: some(0),
        ));
      });
    });

    var resp = await useCase.call(params).run();

    resp.fold((l) => fail(l.message), (r) {
      expect(r.name, some(params.userId));
    });

    verify(repo.getRoomWithUserId(userId: params.userId)).called(1);
    verifyNoMoreInteractions(repo);
  });
}
