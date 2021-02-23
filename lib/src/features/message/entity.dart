part of qiscus_chat_sdk.usecase.message;

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
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QMessage &&
          runtimeType == other.runtimeType &&
          uniqueId == other.uniqueId;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
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
  final Option<int> id;
  final Option<int> chatRoomId, previousMessageId;
  final Option<String> uniqueId, text;
  final Option<QMessageStatus> status;
  final Option<QMessageType> type;
  final Option<Map<String, dynamic>> extras, payload;
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
    Option<int> id,
    Option<int> chatRoomId,
    Option<int> previousMessageId,
    Option<String> uniqueId,
    Option<String> text,
    Option<QMessageStatus> status,
    Option<QMessageType> type,
    Option<Map<String, dynamic>> extras,
    Option<Map<String, dynamic>> payload,
    Option<User> sender,
    Option<DateTime> timestamp,
  }) =>
      Message._(
        id: id ?? Option.none(),
        chatRoomId: chatRoomId ?? Option.none(),
        previousMessageId: previousMessageId ?? Option.none(),
        uniqueId: uniqueId ?? Option.none(),
        text: text ?? Option.none(),
        status: status ?? Option.none(),
        type: type ?? Option.none(),
        extras: extras ?? Option.none(),
        payload: payload ?? Option.none(),
        sender: sender ?? Option.none(),
        timestamp: timestamp ?? Option.none(),
      );

  factory Message.fromJson(Map<String, dynamic> json) {
    var extras = Option.of(json['extras'] as Object).flatMap(decodeJson);
    var payload = Option.of(json['payload'] as Object).flatMap(decodeJson);

    return Message(
      id: Option.of(json['id'] as int),
      chatRoomId: Option.of(json['room_id'] as int),
      previousMessageId: Option.of(
        json['comment_before_id'] as int,
      ),
      uniqueId: Option.of(json['unique_temp_id'] as String),
      text: Option.of(json['message'] as String),
      status: Option.of(json['status'] as String).map((status) {
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
      type: Option.of(json['type'] as String).map((type) {
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
      extras: extras,
      payload: payload,
      timestamp: Option.of(json['unix_nano_timestamp'] as int).map(
        (it) => DateTime.fromMillisecondsSinceEpoch(
          (it / 1e6).round(),
          isUtc: true,
        ),
      ),
      sender: Option.of(User(
        id: Option.of(json['email'] as String),
        name: Option.of(json['username'] as String),
        avatarUrl: Option.of(json['user_avatar_url'] as String),
      )),
    );
  }

  QMessage toModel() => QMessage(
        id: id.toNullable(),
        sender: sender.map((it) => it.toModel()).toNullable(),
        uniqueId: uniqueId.toNullable(),
        previousMessageId: previousMessageId.toNullable(),
        chatRoomId: chatRoomId.toNullable(),
        extras: extras.toNullable(),
        type: type.map((it) => it).toNullable(),
        timestamp: timestamp.toNullable(),
        text: text.toNullable(),
        status: status.toNullable(),
        payload: payload.toNullable(),
      );

  @override
  String toString() => 'Message('
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
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          runtimeType == other.runtimeType &&
          uniqueId == other.uniqueId;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => uniqueId.hashCode;
}
