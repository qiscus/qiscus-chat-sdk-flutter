import 'dart:async';

import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

final qiscus = QiscusSDK.withAppId('sdksample', callback: (_) {});

Future<QAccount> setUser() async {
  var completer = Completer<QAccount>();
  qiscus.setUser(
      userId: 'guest-1002',
      userKey: 'passkey',
      callback: (user, error) {
        if (error != null) return completer.completeError(error);
        return completer.complete(user);
      });
  return completer.future;
}

Future<QChatRoom> getRoom() async {
  var completer = Completer<QChatRoom>();
  qiscus.getChatRoomWithMessages(
      roomId: 3143607,
      callback: (room, messages, error) {
        print('room: $room');
        print('messages: $messages');
        print('error: $error');
      });
  qiscus.chatUser(
      userId: 'guest-1001',
      callback: (room, error) {
        if (error != null) return completer.completeError(error);
        return completer.complete(room);
      });
  return completer.future;
}

void main() async {
  await setUser();
  var room = await getRoom();
  qiscus.subscribeChatRoom(room);
  qiscus.onMessageReceived((message) {
    print('-: @message.received --> $message');
  });
}
