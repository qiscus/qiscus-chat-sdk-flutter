import 'package:qiscus_chat_sdk/src/domain/message/message-model.dart';
import 'package:qiscus_chat_sdk/src/domain/user/user-model.dart';
import 'package:test/test.dart';

void main() {
  test('QMessage', () {
    var user1 = QUser(id: 'user-1', name: 'username-1');
    var user2 = QUser(id: 'user-2', name: 'username-2');
    var m1 = QMessage(
      id: 1,
      chatRoomId: 1,
      previousMessageId: -1,
      uniqueId: 'id-1',
      text: 'hi there',
      status: QMessageStatus.delivered,
      type: QMessageType.text,
      extras: null,
      payload: null,
      sender: user1,
      timestamp: DateTime.now(),
    );
    var m2 = QMessage(
      id: 2,
      chatRoomId: 1,
      previousMessageId: 1,
      uniqueId: 'id-2',
      text: 'hi there',
      status: QMessageStatus.delivered,
      type: QMessageType.text,
      extras: null,
      payload: null,
      sender: user2,
      timestamp: DateTime.now(),
    );
    var m3 = QMessage(
      id: 3,
      chatRoomId: 1,
      previousMessageId: 2,
      uniqueId: 'id-3',
      text: 'hi there',
      status: QMessageStatus.delivered,
      type: QMessageType.text,
      extras: null,
      payload: null,
      sender: user1,
      timestamp: DateTime.now(),
    );

    expect(m1, isNot(equals(m3)));
    expect(m1, isNot(equals(m2)));
  });

  test('QMessage.toString', () {
    var user1 = QUser(id: 'user-1', name: 'username-1');
    var m1 = QMessage(
      id: 1,
      chatRoomId: 1,
      previousMessageId: -1,
      uniqueId: 'id-1',
      text: 'hi there',
      status: QMessageStatus.delivered,
      type: QMessageType.text,
      extras: null,
      payload: null,
      sender: user1,
      timestamp: DateTime(2021),
    );

    var actual = m1.toString();
    var expected = ''
        'QMessage('
        ' id=1,'
        ' text=hi there,'
        ' chatRoomId=1,'
        ' sender=QUser(user-1),'
        ' uniqueId=id-1,'
        ' type=text,'
        ' status=delivered,'
        ' extras=null,'
        ' payload=null,'
        ' timestamp=2021-01-01 00:00:00.000,'
        ' previousMessageId=-1'
        ')';

    expect(actual, expected);
  });

  test('QMessageType.toString', () {
    var type1 = QMessageType.attachment;
    var type2 = QMessageType.custom;
    var type3 = QMessageType.text;
    var type4 = QMessageType.carousel;

    expect(type1.toString(), 'file_attachment');
    expect(type2.toString(), 'custom');
    expect(type3.toString(), 'text');
    expect(type4.toString(), 'carousel');
  });

  test('QMessageStatus.toString', () {
    var s1 = QMessageStatus.sending;
    var s2 = QMessageStatus.sent;
    var s3 = QMessageStatus.delivered;
    var s4 = QMessageStatus.read;

    expect(s1.toString(), 'sending');
    expect(s2.toString(), 'sent');
    expect(s3.toString(), 'delivered');
    expect(s4.toString(), 'read');
  });
}
