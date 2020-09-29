import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/features/message/message.dart';
import 'package:test/test.dart';

class MockRepo extends Mock implements MessageRepository {}

void main() {
  MessageRepository repo;
  DeleteMessageUseCase useCase;

  setUp(() {
    repo = MockRepo();
    useCase = DeleteMessageUseCase(repo);
  });

  test('DeleteMessageUseCase.call()', () async {
    final param = DeleteMessageParams(['1234']);
    when(repo.deleteMessages(uniqueIds: anyNamed('uniqueIds')))
        .thenReturn(Task(() async {
      return right([
        Message(id: some(1), uniqueId: some('1234')),
      ]);
    }));

    var resp = await useCase.call(param).run();

    resp.fold((err) => fail(err.message), (data) {
      expect(data.first.id, some(1));
      expect(data.first.uniqueId, some('1234'));
    });

    verify(repo.deleteMessages(uniqueIds: param.uniqueIds)).called(1);
    verifyNoMoreInteractions(repo);
  });
}
