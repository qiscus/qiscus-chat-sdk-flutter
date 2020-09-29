import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/features/message/message.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';
import 'package:test/test.dart';

class MockRepo extends Mock implements MessageRepository {}

void main() {
  MessageRepository repo;
  SendMessageUseCase useCase;

  final u = User(id: some('userid'));
  final m = Message(
    id: some(1),
    chatRoomId: some(123),
    uniqueId: some('1234'),
    text: some('text'),
    type: some(QMessageType.text),
    sender: some(u),
  );
  final param = MessageParams(m.toModel());

  setUpAll(() {
    repo = MockRepo();
    useCase = SendMessageUseCase(repo);
  });

  test('SendMessageUseCase.call()', () async {
    when(repo.sendMessage(
      any,
      any,
      type: anyNamed('type'),
      extras: anyNamed('extras'),
      payload: anyNamed('payload'),
      uniqueId: anyNamed('uniqueId'),
    )).thenReturn(Task(() async {
      return right(m);
    }));

    var resp = await useCase.call(param).run();

    resp.fold((err) => fail(err.message), (data) {
      expect(data.id, some(1));
      expect(data.uniqueId, some('1234'));
      expect(data.sender, m.sender);
    });

    var qm = m.toModel();
    verify(repo.sendMessage(
      qm.chatRoomId,
      qm.text,
      type: QMessageType.text.string,
      uniqueId: '1234',
    )).called(1);
    verifyNoMoreInteractions(repo);
  });

  test('SendMessageUseCase.call() without roomId', () async {
    var m = Message(chatRoomId: none());
    var resp = await useCase.call(MessageParams(m.toModel())).run();

    expect(resp, isNot(isNull));
    resp.fold((err) {
      expect(err, isA<QError>());
      expect(err.message, '`roomId` can not be null');
    }, (_) => fail('should not success'));
  });

  test('SendMessageUseCase.call() without text', () async {
    var m = Message(chatRoomId: some(1), text: none());
    var resp = await useCase.call(MessageParams(m.toModel())).run();

    expect(resp, isNot(isNull));
    resp.fold((err) {
      expect(err, isA<QError>());
      expect(err.message, '`text` can not be null');
    }, (_) => fail('should not success'));
  });

  test('SendMessageUseCase.call() without type', () async {
    var m = Message(chatRoomId: some(1), text: some('t'), type: none());
    var resp = await useCase.call(MessageParams(m.toModel())).run();

    expect(resp, isNot(isNull));
    resp.fold((err) {
      expect(err, isA<QError>());
      expect(err.message, '`type` can not be null');
    }, (_) => fail('should not success'));
  });
}
