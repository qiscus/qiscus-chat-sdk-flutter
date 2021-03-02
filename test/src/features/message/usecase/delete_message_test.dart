import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/features/message/message.dart';
import 'package:qiscus_chat_sdk/src/type_utils.dart';
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
        .thenAnswer((_) => Future.value([
              Message(id: Option.some(1), uniqueId: Option.some('1234')),
            ]));

    var data = await useCase.call(param);

    expect(data.first.id, Option.some(1));
    expect(data.first.uniqueId, Option.some('1234'));

    verify(repo.deleteMessages(uniqueIds: param.uniqueIds)).called(1);
    verifyNoMoreInteractions(repo);
  });
}
