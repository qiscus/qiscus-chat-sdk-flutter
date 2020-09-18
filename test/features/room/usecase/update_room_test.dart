import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/features/room/room.dart';
import 'package:test/test.dart';

class MockRepository extends Mock implements IRoomRepository {}

void main() {
  MockRepository repo;
  UpdateRoomUseCase useCase;

  setUp(() {
    repo = MockRepository();
    useCase = UpdateRoomUseCase(repo);
  });

  test('updating room successfully', () async {
    final params = UpdateRoomParams(roomId: 1, name: 'room-name');

    when(repo.updateRoom(
      roomId: anyNamed('roomId'),
      name: anyNamed('name'),
      avatarUrl: anyNamed('avatarUrl'),
      extras: anyNamed('extras'),
    )).thenAnswer((_) {
      return Task(() async {
        return right(ChatRoom(
          id: some(params.roomId),
          name: some(params.name),
        ));
      });
    });

    final resp = await useCase.call(params).run();

    resp.fold(
      (err) => fail(err.message),
      (r) {
        expect(r.id, some(params.roomId));
        expect(r.name, some(params.name));
      },
    );

    verify(repo.updateRoom(roomId: params.roomId, name: params.name)).called(1);
    verifyNoMoreInteractions(repo);
  });
}
