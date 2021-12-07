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
  int id;
  int chatRoomId;
  int previousMessageId;
  String uniqueId;
  String text;
  QMessageStatus status;
  QMessageType type;
  Map<String, dynamic>? extras;
  Map<String, dynamic>? payload;
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

QMessage messageFromJson(Map<String, dynamic> json) {
  var extras = Option.fromNullable(json['extras']).flatMap(decodeJson);
  var payload = Option.fromNullable(json['payload']).flatMap(decodeJson);
  var status = Option.fromNullable(json['status'] as String?).map((status) {
    switch (status) {
      case 'read':
        return QMessageStatus.read;
      case 'delivered':
        return QMessageStatus.delivered;
      case 'sent':
      default:
        return QMessageStatus.sent;
    }
  }).getOrElse(() => QMessageStatus.sent);
  var type = Option.of(json['type'] as String).map((type) {
    switch (type) {
      case 'custom':
        return QMessageType.custom;
      case 'file_attachment':
        return QMessageType.attachment;
      case 'text':
      default:
        return QMessageType.text;
    }
  }).getOrElse(() => QMessageType.text);
  var timestamp = DateTime.fromMillisecondsSinceEpoch(
    ((json['unix_nano_timestamp'] as int) / 1e6).round(),
    isUtc: true,
  );

  var sender = QUser(
    id: json['email'] as String,
    name: json['username'] as String,
    avatarUrl: json['user_avatar_url'] as String,
  );

  return QMessage(
    id: json['id'] as int,
    chatRoomId: json['room_id'] as int,
    previousMessageId: json['comment_before_id'] as int,
    uniqueId: json['unique_temp_id'] as String,
    text: json['message'] as String,
    status: status,
    type: type,
    extras: extras.toNullable(),
    payload: payload.toNullable(),
    timestamp: timestamp,
    sender: sender,
  );
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
