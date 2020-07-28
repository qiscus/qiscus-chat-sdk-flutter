import 'package:get_it/get_it.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';
import 'package:qiscus_chat_sdk/extension.dart';
import 'package:test/test.dart';

void main() async {
  //
  group('QiscusSDK', () {
    QiscusSDK qiscus;

    setUpAll(() {
      qiscus = QiscusSDK();
    });

    test('should use the correct appId', () async {
      await qiscus.setup$('sdksample');
      expect(qiscus.appId, 'sdksample');
    });
  }, skip: true);

  group('Bug', () {
    QiscusSDK qiscus;

    setUpAll(() async {
      qiscus = await QiscusSDK.withAppId$('sdksample');
    });

    test('generate custom message', () async {
      await qiscus.setup$('sdksample');
      // qiscus.enableDebugMode(enable: true, level: QLogLevel.verbose);
      await qiscus.setUser$(userId: 'guest-1001', userKey: 'passkey');
      var room = await qiscus.chatUser$(userId: 'guest-101');
      var message0 = qiscus.generateCustomMessage(
        chatRoomId: room.id,
        text: 'text message ini',
        type: 'tipe-message',
        payload: <String, dynamic>{
          'p1': 'p1-value',
        },
      );
      var message1 = await qiscus.sendMessage$(message: message0);
      expect(message1.type, QMessageType.custom);
      expect(message1.payload['type'], 'tipe-message');
      expect(message1.text, 'text message ini');
    }, skip: true);

    test('not calling delivery event callback', () async {
      var qiscus1 = await QiscusSDK.withAppId$('sdksample');
      var qiscus2 = await QiscusSDK.withAppId$('sdksample');

      await qiscus1.setUser$(userId: 'guest-1001', userKey: 'passkey');
      await qiscus2.setUser$(userId: 'guest-1002', userKey: 'passkey');

      var room = await qiscus1.chatUser$(userId: 'guest-1002');
      var message = qiscus1.generateMessage(
        chatRoomId: room.id,
        text: 'Ini text',
      );

      qiscus1.subscribeChatRoom(room);
      qiscus1.onMessageDelivered(expectAsync1((m) {
        print('on message delivered');
        expect(m.uniqueId, message.uniqueId);
      }));
      qiscus2.onMessageRead(expectAsync1((m) {
        print('on message read');
        expect(m.uniqueId, message.uniqueId);
      }));

      qiscus2.subscribeChatRoom(room);
      qiscus2.onMessageReceived(expectAsync1((m) {
        print('on message received');
        expect(m.uniqueId, message.uniqueId);
      }, max: 5));

      var m1 = await qiscus1.sendMessage$(message: message);
      expect(m1.uniqueId, message.uniqueId);
      message = m1;

//      qiscus2.markAsDelivered(roomId: room.id, messageId: message.id, callback: expectAsync1((err) {
//        throwIf(err != null, err);
//      }, reason: 'marking as delivered'));
      qiscus2.markAsRead(
          roomId: room.id,
          messageId: message.id,
          callback: expectAsync1((err) {
            throwIf(err != null, err);
          }, reason: 'marking as read'));
    }, timeout: Timeout.factor(1.2));
  }, skip: true);
}
