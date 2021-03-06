import 'package:qiscus_chat_sdk/src/message/message.dart';
import 'package:qiscus_chat_sdk/src/user/user.dart';
import 'package:qiscus_chat_sdk/src/type_utils.dart';
import 'package:test/test.dart';

void main() {
  group('QMessage', () {
    var m1 = QMessage(
      id: 1,
      chatRoomId: 1,
      previousMessageId: 1,
      uniqueId: 'unique-id',
      text: 'text',
      status: QMessageStatus.read,
      type: QMessageType.text,
      extras: <String, dynamic>{},
      payload: <String, dynamic>{},
      sender: QUser(id: 'user-id'),
      timestamp: DateTime.now(),
    );
    var m11 = QMessage(
      id: 1,
      chatRoomId: 1,
      previousMessageId: 1,
      uniqueId: 'unique-id',
      text: 'text',
      status: QMessageStatus.read,
      type: QMessageType.text,
      extras: <String, dynamic>{},
      payload: <String, dynamic>{},
      sender: QUser(id: 'user-id'),
      timestamp: DateTime.now(),
    );
    var m2 = QMessage(
      id: 2,
      chatRoomId: 1,
      previousMessageId: 1,
      uniqueId: 'unique-id-2',
      text: 'text',
      status: QMessageStatus.read,
      type: QMessageType.text,
      extras: <String, dynamic>{},
      payload: <String, dynamic>{},
      sender: QUser(id: 'user-id'),
      timestamp: DateTime.now(),
    );

    test('stringify QMessageType', () {
      expect(QMessageTypeString(QMessageType.text).string, 'text');
      expect(QMessageTypeString(QMessageType.attachment).string,
          'file_attachment');
      expect(QMessageTypeString(QMessageType.custom).string, 'custom');
    });

    test('stringify QMessageStatus', () {
      expect(QMessageStatusStr(QMessageStatus.delivered).string, 'delivered');
      expect(QMessageStatusStr(QMessageStatus.read).string, 'read');
      expect(QMessageStatusStr(QMessageStatus.sent).string, 'sent');
      expect(QMessageStatusStr(QMessageStatus.sending).string, 'sending');
    });

    test('QMessage.toString()', () async {
      final str = 'QMessage('
          ' id=${m1.id},'
          ' text=${m1.text},'
          ' chatRoomId=${m1.chatRoomId},'
          ' sender=${m1.sender},'
          ' uniqueId=${m1.uniqueId},'
          ' type=${m1.type},'
          ' status=${m1.status},'
          ' extras=${m1.extras},'
          ' payload=${m1.payload},'
          ' timestamp=${m1.timestamp},'
          ' previousMessageId=${m1.previousMessageId}'
          ')';

      expect(m1.toString(), str);
    });

    test('Qmessage m1 == QMessage m11', () {
      expect(m1, m11);
      expect(m1.hashCode, m11.hashCode);
    });
    test('QMessage m1 != QMessage m2', () {
      expect(m1, isNot(m2));
      expect(m1.hashCode, isNot(m2.hashCode));
    });
  });

  group('Message', () {
    var timestamp = DateTime.now();
    var m1 = Message(
      id: Option.some(1),
      chatRoomId: Option.some(1),
      previousMessageId: Option.some(1),
      uniqueId: Option.some('unique-id'),
      text: Option.some('text'),
      status: Option.some(QMessageStatus.read),
      type: Option.some(QMessageType.text),
      extras: Option.some(<String, dynamic>{}),
      payload: Option.some(<String, dynamic>{}),
      sender: Option.some(User(id: Option.some('user-id'))),
      timestamp: Option.some(timestamp),
    );
    var m11 = Message(
      id: Option.some(1),
      chatRoomId: Option.some(1),
      previousMessageId: Option.some(1),
      uniqueId: Option.some('unique-id'),
      text: Option.some('text'),
      status: Option.some(QMessageStatus.read),
      type: Option.some(QMessageType.text),
      extras: Option.some(<String, dynamic>{}),
      payload: Option.some(<String, dynamic>{}),
      sender: Option.some(User(id: Option.some('user-id'))),
      timestamp: Option.some(DateTime.now()),
    );
    var m2 = Message(
      id: Option.some(2),
      chatRoomId: Option.some(1),
      previousMessageId: Option.some(1),
      uniqueId: Option.some('unique-id-2'),
      text: Option.some('text'),
      status: Option.some(QMessageStatus.read),
      type: Option.some(QMessageType.text),
      extras: Option.some(<String, dynamic>{}),
      payload: Option.some(<String, dynamic>{}),
      sender: Option.some(User(id: Option.some('user-id'))),
      timestamp: Option.some(DateTime.now()),
    );

    test('Message.toString()', () async {
      final str = 'Message('
          ' id=${m1.id},'
          ' text=${m1.text},'
          ' chatRoomId=${m1.chatRoomId},'
          ' sender=${m1.sender},'
          ' uniqueId=${m1.uniqueId},'
          ' type=${m1.type},'
          ' status=${m1.status},'
          ' extras=${m1.extras},'
          ' payload=${m1.payload},'
          ' timestamp=${m1.timestamp},'
          ' previousMessageId=${m1.previousMessageId}'
          ')';

      expect(m1.toString(), str);
    });

    test('Message m1 == Message m11', () {
      expect(m1, m11);
      expect(m1.hashCode, m11.hashCode);
    });
    test('Message m1 != Message m2', () {
      expect(m1, isNot(m2));
      expect(m1.hashCode, isNot(m2.hashCode));
    });

    test('Message.toModel()', () {
      var model = m1.toModel();

      expect(model.id, 1);
      expect(model.chatRoomId, 1);
      expect(model.previousMessageId, 1);
      expect(model.uniqueId, 'unique-id');
      expect(model.text, 'text');
      expect(model.status, QMessageStatus.read);
      expect(model.type, QMessageType.text);
      expect(model.extras.keys.length, 0);
      expect(model.payload.keys.length, 0);
      expect(model.sender.id, 'user-id');
      expect(model.timestamp, timestamp);
    });
  });
}
