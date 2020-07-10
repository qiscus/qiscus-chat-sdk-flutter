import 'dart:async';

import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';
import 'package:test/test.dart';

void main() {
  QiscusSDK qiscus;
  QChatRoom roomToUpdate;

  group('Bug room extras data', () {
    setUpAll(() async {
      qiscus = await QiscusSDK.withAppId$('sdksample');
      qiscus.enableDebugMode(enable: true, level: QLogLevel.verbose);
      await qiscus.setUser$(userId: 'guest-1001', userKey: 'passkey');
      roomToUpdate = await qiscus.createGroupChat$(
        name: 'room-to-update',
        userIds: ['guest-101'],
      );
    });

    test('create room with correct extras data', () async {
      var extras = {
        'name': 'extras-1',
        'key': 'value',
        'time': DateTime.now().millisecondsSinceEpoch,
      };
      var room = await qiscus.createGroupChat$(
        name: 'group-chat-1',
        userIds: ['guest-1002'],
        extras: extras,
      );

      expect(room.extras['name'], extras['name']);
      expect(room.extras['key'], extras['key']);
    });

    test('update room with correct extras data', () async {
      var extras = <String, dynamic>{
        'name': 'extras-2',
        'key': 'value',
        'time': DateTime.now().millisecondsSinceEpoch,
      };
      var completer = Completer<QChatRoom>();
      qiscus.updateChatRoom(
        roomId: roomToUpdate.id,
        extras: extras,
        callback: (r, err) {
          if (err != null) return completer.completeError(err);
          completer.complete(r);
        },
      );

      var room = await completer.future;
      expect(room.id, roomToUpdate.id);
      expect(room.extras['name'], extras['name']);
      expect(room.extras['key'], extras['key']);
      expect(room.extras['time'], extras['time']);
    });
  });
}
