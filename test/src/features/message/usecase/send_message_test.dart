import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/features/message/message.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';
import 'package:qiscus_chat_sdk/src/type_utils.dart';
import 'package:test/test.dart';

class MockRepo extends Mock implements MessageRepository {}

void main() {
  MessageRepository repo;
  SendMessageUseCase useCase;

  final u = User(id: Option.some('userid'));
  final m = Message(
    id: Option.some(1),
    chatRoomId: Option.some(123),
    uniqueId: Option.some('1234'),
    text: Option.some('text'),
    type: Option.some(QMessageType.text),
    sender: Option.some(u),
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
    )).thenAnswer((_) => Future.value(m));

    var data = await useCase.call(param);

    expect(data.id, Option.some(1));
    expect(data.uniqueId, Option.some('1234'));
    expect(data.sender, m.sender);

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
    var m = Message(chatRoomId: Option.none());
    try {
      await useCase.call(MessageParams(m.toModel()));
    } catch (err) {
      expect(err, isA<QError>());
      expect(err.toString(), '`roomId` can not be null');
    }
  });

  test('SendMessageUseCase.call() without text', () async {
    var m = Message(chatRoomId: Option.some(1), text: Option.none());

    try {
      await useCase.call(MessageParams(m.toModel()));
    } catch (err) {
      expect(err, isA<QError>());
      expect(err.toString(), '`text` can not be null');
    }
  });

  test('SendMessageUseCase.call() without type', () async {
    var m = Message(
        chatRoomId: Option.some(1),
        text: Option.some('t'),
        type: Option.none());

    try {
      await useCase.call(MessageParams(m.toModel()));
    } catch (err) {
      expect(err, isA<QError>());
      expect(err.toString(), '`type` can not be null');
    }
  });
}
