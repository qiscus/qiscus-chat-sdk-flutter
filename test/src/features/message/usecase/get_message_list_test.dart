import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/features/message/message.dart';
import 'package:test/test.dart';

class MockRepo extends Mock implements MessageRepository {}

void main() {
  MessageRepository repo;
  GetMessageListUseCase useCase;

  setUp(() {
    repo = MockRepo();
    useCase = GetMessageListUseCase(repo);
  });

  test('GetMessageListUseCase.call()', () async {
    final param = GetMessageListParams(1, 12);
    when(repo.getMessages(
      any,
      any,
      after: anyNamed('after'),
      limit: anyNamed('limit'),
    )).thenReturn(Task(() async {
      return right([
        Message(id: some(1), uniqueId: some('1234')),
      ]);
    }));

    var resp = await useCase.call(param).run();

    resp.fold((err) => fail(err.message), (data) {
      expect(data.first.id, some(1));
      expect(data.first.uniqueId, some('1234'));
    });

    verify(repo.getMessages(1, 12)).called(1);
    verifyNoMoreInteractions(repo);
  });
}
