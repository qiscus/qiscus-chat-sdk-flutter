import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/message/message.dart';
import 'package:test/test.dart';

class MockRepo extends Mock implements MessageRepository {}

void main() {
  MessageRepository repo;
  UpdateMessageStatusUseCase useCase;

  setUp(() {
    repo = MockRepo();
    useCase = UpdateMessageStatusUseCase(repo);
  });

  test('UpdateMessageStatusUseCase.call() read', () async {
    final param = UpdateStatusParams(12, 1, QMessageStatus.read);
    when(repo.updateStatus(
      deliveredId: anyNamed('deliveredId'),
      readId: anyNamed('readId'),
      roomId: anyNamed('roomId'),
    )).thenAnswer((_) => Future.value(null));

    await useCase.call(param);

    verify(repo.updateStatus(roomId: 12, readId: 1)).called(1);
    verifyNoMoreInteractions(repo);
  });

  test('UpdateMessageStatusUseCase.call() deliver', () async {
    final param = UpdateStatusParams(12, 1, QMessageStatus.delivered);
    when(repo.updateStatus(
      deliveredId: anyNamed('deliveredId'),
      readId: anyNamed('readId'),
      roomId: anyNamed('roomId'),
    )).thenAnswer((_) => Future.value(null));

    await useCase.call(param);

    verify(repo.updateStatus(roomId: 12, deliveredId: 1)).called(1);
    verifyNoMoreInteractions(repo);
  });

  test('UpdateMessageStatusUseCase.call() others', () async {
    final param = UpdateStatusParams(12, 1, QMessageStatus.sent);

    try {
      await useCase.call(param);
    } catch (err) {
      expect(err, isA<QError>());
      expect(
        err.toString(),
        'Can not update status for message with status: QMessageStatus.sent',
      );
    }
  });
}
