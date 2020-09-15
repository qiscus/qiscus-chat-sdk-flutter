import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/features/room/room.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

class MockRoomRepo extends Mock implements IRoomRepository {}

void main() {
  IRoomRepository repo;
  CreateGroupChatUseCase useCase;

  setUpAll(() {
    repo = MockRoomRepo();
    useCase = CreateGroupChatUseCase(repo);
  });

  test('create group successfully', () async {
    var params = CreateGroupChatParams(
      name: 'name',
      userIds: ['user1', 'user2'],
      extras: <String, dynamic>{
        'key': 'value',
      },
    );

    // ignore: missing_required_param
    var room = ChatRoom(
      uniqueId: 'unique-id'.toOption(),
      name: some('room-name'),
      id: some(123),
    );
    when(repo.createGroup(
      name: anyNamed('name'),
      userIds: anyNamed('userIds'),
      avatarUrl: anyNamed('avatarUrl'),
      extras: anyNamed('extras'),
    )).thenAnswer((_) => Task(() async => right(room)));

    var resp = await useCase.call(params).run();

    resp.fold((l) => fail(l.message), (r) {
      expect(r.id, room.id);
      expect(r.uniqueId, room.uniqueId);
    });

    verify(repo.createGroup(
      name: params.name,
      userIds: params.userIds,
      extras: params.extras,
    ));
    verifyNoMoreInteractions(repo);
  });
}
