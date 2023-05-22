import 'package:qiscus_chat_sdk/src/domain/commons.dart';
import 'package:qiscus_chat_sdk/src/domain/domains.dart';
import 'package:test/test.dart';

void main() {
  test('QHook', () {
    void callback1() {}
    var hook1 = QHook(QInterceptor.messageBeforeReceived, callback1);
    var hook2 = QHook(QInterceptor.messageBeforeReceived, callback1);
    expect(hook1, hook2);

    void callback2() {}
    var hook3 = QHook(QInterceptor.messageBeforeReceived, callback2);
    expect(hook1, isNot(hook3));
  });

  test('QDeviceToken', () {
    var token1 = QDeviceToken('token-1', false);
    var token2 = QDeviceToken('token-1');
    expect(token1, token2);

    var token3 = QDeviceToken('token-1', true);
    expect(token1, isNot(token3));
  });

  test('QChatRoomWithMessages', () {
    var room = QChatRoom(id: 1, uniqueId: '1');
    var message1 = QMessage(
      id: 1,
      chatRoomId: 1,
      previousMessageId: 1,
      uniqueId: '1',
      text: 'text',
      status: QMessageStatus.read,
      type: QMessageType.text,
      extras: null,
      payload: null,
      sender: QUser(id: 'user-id', name: 'user-name'),
      timestamp: DateTime.now(),
    );
    var message2 = QMessage(
      id: 2,
      chatRoomId: 1,
      previousMessageId: 1,
      uniqueId: '1',
      text: 'text',
      status: QMessageStatus.read,
      type: QMessageType.text,
      extras: null,
      payload: null,
      sender: QUser(id: 'user-id', name: 'user-name'),
      timestamp: DateTime.now(),
    );

    var data1 = QChatRoomWithMessages(room, [message1]);
    var data2 = QChatRoomWithMessages(room, [message1]);
    expect(data1, data2);

    var data3 = QChatRoomWithMessages(room, [message1, message2]);
    expect(data1, isNot(data3));
  });

  test('QUploadProgress', () {
    var data1 = QUploadProgress(progress: 1, data: 1);
    var data2 = QUploadProgress(progress: 1, data: 1);
    expect(data1, data2);

    var data3 = QUploadProgress(progress: 1, data: '1');
    expect(data1, isNot(data3));
  });
}
