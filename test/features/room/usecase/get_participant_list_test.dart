import 'package:qiscus_chat_sdk/src/features/message/message.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository.dart';
import 'package:qiscus_chat_sdk/src/features/room/room.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

class MockRepo extends Mock implements IRoomRepository {}

void main() {
  IRoomRepository repo;

  setUpAll(() {
    repo = MockRepo();
  });

  group('GetParticipants', () {
    GetParticipantsUseCase useCase;

    setUpAll(() {
      useCase = GetParticipantsUseCase(repo);
    });

    test('get participant list successfully', () async {
      when(repo.getParticipants(any)).thenReturn(Task(() async {
        return right(GetParticipantsResponse('unique-id', <Participant>[
          Participant(
            id: 'id',
            name: some('name'),
            avatarUrl: none(),
            lastReadMessageId: some(1),
            lastReceivedMessageId: some(1),
            extras: none(),
          ),
        ]));
      }));

      var resp = await useCase.call(RoomUniqueIdsParams('unique-id')).run();
      resp.fold((l) => fail(l.message), (r) {
        expect(r.first.id, 'id');
        expect(r.first.name, some('name'));
      });

      verify(repo.getParticipants('unique-id')).called(1);
      verifyNoMoreInteractions(repo);
    });
  });
  group('AddParticipant', () {
    AddParticipantUseCase useCase;

    setUpAll(() {
      useCase = AddParticipantUseCase(repo);
    });

    test('add participant successfully', () async {
      var roomId = 123;
      var participantIds = <String>['123'];
      when(repo.addParticipant(any, any)).thenReturn(Task(() async {
        return right(AddParticipantResponse(roomId, <Participant>[
          Participant(id: '123'),
        ]));
      }));

      var resp =
          await useCase.call(ParticipantParams(roomId, participantIds)).run();

      resp.fold((l) => fail(l.message), (r) {
        expect(r.first.id, '123');
      });
      verify(repo.addParticipant(roomId, participantIds)).called(1);
      verifyNoMoreInteractions(repo);
    });
  });
  group('RemoveParticipant', () {
    RemoveParticipantUseCase useCase;
    setUpAll(() {
      useCase = RemoveParticipantUseCase(repo);
    });

    test('remove participant successfully', () async {
      var roomId = 123;
      var participantIds = <String>['123'];
      when(repo.removeParticipant(roomId, participantIds))
          .thenReturn(Task(() async {
        return right(RemoveParticipantResponse(roomId, participantIds));
      }));

      var params = ParticipantParams(roomId, participantIds);
      var resp = await useCase.call(params).run();

      resp.fold((l) => fail(l.message), (r) {
        expect(r.first, participantIds.first);
      });

      verify(repo.removeParticipant(roomId, participantIds)).called(1);
      verifyNoMoreInteractions(repo);
    });
  });
}
