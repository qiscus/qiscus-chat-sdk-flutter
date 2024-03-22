import 'package:equatable/equatable.dart';
import 'package:qiscus_chat_sdk/src/domain/user/user-model.dart';

import '../../core.dart';

enum QMessageType {
  text,
  custom,
  attachment,
  reply;

  @override
  String toString() {
    switch (this) {
      case text:
        return 'text';
      case custom:
        return 'custom';
      case attachment:
        return 'file_attachment';
      case reply:
        return 'reply';
    }
  }
}

class QMessage with EquatableMixin {
  int id;
  int chatRoomId;
  int previousMessageId;
  String uniqueId;
  String text;
  QMessageStatus status;
  QMessageType type;
  Json? extras;
  Json? payload;
  QUser sender;
  DateTime timestamp;

  QMessage({
    required this.id,
    required this.chatRoomId,
    required this.previousMessageId,
    required this.uniqueId,
    required this.text,
    required this.status,
    required this.type,
    required this.extras,
    required this.payload,
    required this.sender,
    required this.timestamp,
  });

  @override
  String toString() => 'QMessage('
      ' id=$id,'
      ' text=$text,'
      ' chatRoomId=$chatRoomId,'
      ' sender=$sender,'
      ' uniqueId=$uniqueId,'
      ' type=$type,'
      ' status=$status,'
      ' extras=$extras,'
      ' payload=$payload,'
      ' timestamp=$timestamp,'
      ' previousMessageId=$previousMessageId'
      ')';

  @override
  List<Object?> get props => [id, chatRoomId, sender, uniqueId];
}

enum QMessageStatus {
  sending,
  sent,
  delivered,
  read;

  String toString() {
    switch (this) {
      case sending:
        return 'sending';
      case sent:
        return 'sent';
      case delivered:
        return 'delivered';
      case read:
        return 'read';
    }
  }
}
