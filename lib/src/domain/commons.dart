import 'package:equatable/equatable.dart';

import 'message/message-model.dart';
import 'room/room-model.dart';

class QHook with EquatableMixin {
  final QInterceptor hook;
  final Function callback;

  const QHook(this.hook, this.callback);

  @override
  List<Object?> get props => [hook, callback];
}

class QDeviceToken {
  const QDeviceToken(this.token, [this.isDevelopment = false]);

  final String token;
  final bool isDevelopment;
  final deviceType = 'flutter';
}

class QChatRoomWithMessages with EquatableMixin {
  const QChatRoomWithMessages(this.room, this.messages);

  final QChatRoom room;
  final List<QMessage> messages;

  @override
  List<Object> get props => [room, messages];
}

enum QInterceptor {
  messageBeforeSent,
  messageBeforeReceived,
}

class QUploadProgress<T extends Object> {
  const QUploadProgress({required this.progress, this.data});
  final double progress;
  final T? data;
}
