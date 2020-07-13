import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/features/channel/channel.dart';
import 'package:qiscus_chat_sdk/src/features/room/entity.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

class MockRepo extends Mock implements IRoomRepository {}

void main() {
  IRoomRepository repo;
  GetOrCreateChannelUseCase useCase;

  setUpAll(() {
    repo = MockRepo();
    useCase = GetOrCreateChannelUseCase(repo);
  });

  test('create channel successfully', () async {
    when(repo.getOrCreateChannel(
      uniqueId: anyNamed('uniqueId'),
      name: anyNamed('name'),
      avatarUrl: anyNamed('avatarUrl'),
      options: anyNamed('options'),
    )).thenReturn(Task(() async {
      return right(ChatRoom(
        uniqueId: '123',
        type: QRoomType.channel,
        id: some(123),
        name: some('name'),
        unreadCount: some(0),
        avatarUrl: some('avatar'),
        totalParticipants: some(2),
        extras: none(),
        participants: none(),
        lastMessage: none(),
        sender: none(),
      ));
    }));
    var resp = await useCase
        .call(GetOrCreateChannelParams(
          '123',
          name: 'name',
          avatarUrl: 'avatar',
        ))
        .run();

    resp.fold((l) => fail(l.message), (r) {
      expect(r.name, some('name'));
      expect(r.uniqueId, '123');
    });

    verify(repo.getOrCreateChannel(
      uniqueId: '123',
      name: 'name',
      avatarUrl: 'avatar',
    )).called(1);
    verifyNoMoreInteractions(repo);
  });
}
