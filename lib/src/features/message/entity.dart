import 'dart:io' if (dart.library.html) 'dart:html';
import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/user.dart';

enum QMessageType {
  text,
  custom,
  attachment,
}

extension QMessageTypeString on QMessageType {
  String get string {
    switch (this) {
      case QMessageType.attachment:
        return 'file_attachment';
      case QMessageType.custom:
        return 'custom';
      case QMessageType.text:
      default:
        return 'text';
    }
  }
}

class QMessage {
  int id, chatRoomId, previousMessageId;
  String uniqueId, text;
  QMessageStatus status;
  QMessageType type;
  Map<String, dynamic> extras, payload;
  QUser sender;
  DateTime timestamp;

  QMessage({
    @required this.id,
    @required this.chatRoomId,
    @required this.previousMessageId,
    @required this.uniqueId,
    @required this.text,
    @required this.status,
    @required this.type,
    @required this.extras,
    @required this.payload,
    @required this.sender,
    @required this.timestamp,
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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QMessage &&
          runtimeType == other.runtimeType &&
          uniqueId == other.uniqueId;

  @override
  int get hashCode => uniqueId.hashCode;
}

enum QMessageStatus {
  sending,
  sent,
  delivered,
  read,
}

extension QMessageStatusStr on QMessageStatus {
  String get string {
    switch (this) {
      case QMessageStatus.sending:
        return 'sending';
      case QMessageStatus.delivered:
        return 'delivered';
      case QMessageStatus.read:
        return 'read';
      case QMessageStatus.sent:
      default:
        return 'sent';
    }
  }
}

@sealed
class Message {
  final int id;
  final Option<int> chatRoomId, previousMessageId;
  final Option<String> uniqueId, text;
  final Option<QMessageStatus> status;
  final Option<QMessageType> type;
  final Option<IMap<String, dynamic>> extras, payload;
  final Option<User> sender;
  final Option<DateTime> timestamp;

  Message._({
    @required this.id,
    this.chatRoomId,
    this.previousMessageId,
    this.uniqueId,
    this.text,
    this.status,
    this.type,
    this.extras,
    this.payload,
    this.sender,
    this.timestamp,
  });

  factory Message({
    @required int id,
    Option<int> chatRoomId,
    Option<int> previousMessageId,
    Option<String> uniqueId,
    Option<String> text,
    Option<QMessageStatus> status,
    Option<QMessageType> type,
    Option<IMap<String, dynamic>> extras,
    Option<IMap<String, dynamic>> payload,
    Option<User> sender,
    Option<DateTime> timestamp,
  }) =>
      Message._(
        id: id,
        chatRoomId: chatRoomId ?? none(),
        previousMessageId: previousMessageId ?? none(),
        uniqueId: uniqueId ?? none(),
        text: text ?? none(),
        status: status ?? none(),
        type: type ?? none(),
        extras: extras ?? none(),
        payload: payload ?? none(),
        sender: sender ?? none(),
        timestamp: timestamp ?? none(),
      );

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      chatRoomId: optionOf(json['room_id'] as int),
      previousMessageId: optionOf(
        json['comment_before_id'] as int,
      ),
      uniqueId: optionOf(json['unique_temp_id'] as String),
      text: optionOf(json['message'] as String),
      status: optionOf(json['status'] as String).map((status) {
        switch (status) {
          case 'read':
            return QMessageStatus.read;
          case 'delivered':
            return QMessageStatus.delivered;
          case 'sent':
          default:
            return QMessageStatus.sent;
        }
      }),
      type: optionOf(json['type'] as String).map((type) {
        switch (type) {
          case 'custom':
            return QMessageType.custom;
          case 'file_attachment':
            return QMessageType.attachment;
          case 'text':
          default:
            return QMessageType.text;
        }
      }),
      extras: optionOf(json['extras'] as Map<String, dynamic>).map(imap),
      payload: optionOf(json['payload'] as Map<String, dynamic>).map(imap),
      timestamp: optionOf(json['unix_nano_timestamp'] as int)
          .map((it) => DateTime.fromMillisecondsSinceEpoch((it / 1e6).ceil())),
      sender: optionOf(User(
        id: json['email'] as String,
        name: optionOf(json['username'] as String),
        avatarUrl: optionOf(json['user_avatar_url'] as String),
      )),
    );
  }

  QMessage toModel() => QMessage(
        id: id,
        sender: sender.map((it) => it.toModel()).toNullable(),
        uniqueId: uniqueId.toNullable(),
        previousMessageId: previousMessageId.toNullable(),
        chatRoomId: chatRoomId.toNullable(),
        extras: extras.map((it) => it.toMap()).toNullable(),
        type: type.map((it) => it).toNullable(),
        timestamp: timestamp.toNullable(),
        text: text.toNullable(),
        status: status.toNullable(),
        payload: payload.map((it) => it.toMap()).toNullable(),
      );
}
