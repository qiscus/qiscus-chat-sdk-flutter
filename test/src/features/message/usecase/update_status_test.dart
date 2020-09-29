import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/features/message/message.dart';
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
    )).thenReturn(Task(() async => right(unit)));

    var resp = await useCase.call(param).run();

    resp.fold((err) => fail(err.message), (data) {});

    verify(repo.updateStatus(roomId: 12, readId: 1)).called(1);
    verifyNoMoreInteractions(repo);
  });

  test('UpdateMessageStatusUseCase.call() deliver', () async {
    final param = UpdateStatusParams(12, 1, QMessageStatus.delivered);
    when(repo.updateStatus(
      deliveredId: anyNamed('deliveredId'),
      readId: anyNamed('readId'),
      roomId: anyNamed('roomId'),
    )).thenReturn(Task(() async => right(unit)));

    var resp = await useCase.call(param).run();

    resp.fold((err) => fail(err.message), (data) {});

    verify(repo.updateStatus(roomId: 12, deliveredId: 1)).called(1);
    verifyNoMoreInteractions(repo);
  });

  test('UpdateMessageStatusUseCase.call() others', () async {
    final param = UpdateStatusParams(12, 1, QMessageStatus.sent);

    var resp = await useCase.call(param).run();

    resp.fold((err) {
      expect(err, isA<QError>());
      expect(
        err.message,
        'Can not update status for message with status: QMessageStatus.sent',
      );
    }, (_) => fail('should not sucess'));
  });
}
