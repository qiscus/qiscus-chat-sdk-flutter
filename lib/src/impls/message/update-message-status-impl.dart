import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/message/message-model.dart';

RTE<Unit> updateMessageStatusImpl(
  int roomId,
  int messageId,
  QMessageStatus status,
) {
  return Reader((dio) {
    return tryCatch(() async {
      switch (status) {
        case QMessageStatus.delivered:
          return UpdateMessageStatusRequest(
            roomId: roomId,
            lastDeliveredId: messageId,
          )(dio).then((_) => unit);
        case QMessageStatus.read:
          return UpdateMessageStatusRequest(
            roomId: roomId,
            lastReadId: messageId,
          )(dio).then((_) => unit);
        case QMessageStatus.sending:
        case QMessageStatus.sent:
          return unit;
      }
    });
  });
}

class UpdateMessageStatusRequest extends IApiRequest<void> {
  final int roomId;
  final int? lastReadId;
  final int? lastDeliveredId;

  UpdateMessageStatusRequest({
    required this.roomId,
    this.lastReadId,
    this.lastDeliveredId,
  });

  @override
  String get url => 'update_comment_status';
  @override
  IRequestMethod get method => IRequestMethod.post;
  @override
  Map<String, dynamic> get body => <String, dynamic>{
        'room_id': roomId.toString(),
        'last_comment_read_id': lastReadId?.toString(),
        'last_comment_received_id': lastDeliveredId?.toString(),
      };

  @override
  void format(json) {
    return null;
  }
}
