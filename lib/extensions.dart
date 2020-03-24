library qiscus_chat_sdk;

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';

extension CQiscusSDK on QiscusSDK {
  Future<void> setup$(String appId) {
    var completer = Completer<void>();
    setup(appId, callback: (error) {
      if (error != null) {
        completer.completeError(error);
      } else {
        completer.complete();
      }
    });
    return completer.future;
  }

  Future<QAccount> setUser$({
    @required String userId,
    @required String userKey,
    String username,
  }) {
    var completer = Completer<QAccount>();
    setUser(
      userId: userId,
      userKey: userKey,
      username: username,
      callback: (user, error) {
        if (error != null) {
          completer.completeError(error);
        } else {
          completer.complete(user);
        }
      },
    );
    return completer.future;
  }

  Future<QChatRoom> chatUser$({
    @required String userId,
  }) {
    var completer = Completer<QChatRoom>();
    chatUser(
      userId: userId,
      callback: (room, error) {
        if (error != null) {
          completer.completeError(error);
        } else {
          completer.complete(room);
        }
      },
    );
    return completer.future;
  }
}
