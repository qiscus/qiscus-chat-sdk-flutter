import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/message/message.dart';
import 'package:qiscus_chat_sdk/src/type_utils.dart';
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
    )).thenAnswer((_) => Future.value(
          [Message(id: Option.some(1), uniqueId: Option.some('1234'))],
        ));

    var data = await useCase.call(param);

    expect(data.first.id, Option.some(1));
    expect(data.first.uniqueId, Option.some('1234'));

    verify(repo.getMessages(1, 12)).called(1);
    verifyNoMoreInteractions(repo);
  });
}
