import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/api_request.dart';

import 'entity.dart';

class SendMessageRequest extends IApiRequest<Message> {
  final int roomId;
  final String message;
  final String type;
  final String uniqueId;
  final Map<String, dynamic> extras;
  final Map<String, dynamic> payload;

  SendMessageRequest({
    @required this.roomId,
    @required this.message,
    this.uniqueId,
    this.type = 'text',
    this.extras,
    this.payload,
  });

  get url => 'post_comment';
  get method => IRequestMethod.post;
  get body => <String, dynamic>{
        'topic_id': roomId,
        'comment': message,
        'type': type,
        'unique_temp_id': uniqueId,
        'payload': payload,
        'extras': extras,
      };

  format(Map<String, dynamic> json) {
    var data = json['results']['comment'] as Map<String, dynamic>;
    return Message.fromJson(data);
  }
}

class GetMessagesRequest extends IApiRequest<List<Message>> {
  final int roomId;
  final int lastMessageId;
  final int limit;
  final bool after;

  GetMessagesRequest({
    @required this.roomId,
    @required this.lastMessageId,
    this.after = false,
    this.limit = 20,
  });

  get url => 'load_comments';
  get method => IRequestMethod.get;
  get params => <String, dynamic>{
        'topic_id': roomId,
        'last_comment_id': lastMessageId,
        'after': after,
        'limit': limit,
      };

  format(json) {
    var data = (json['results']['comments'] as List) //
        .cast<Map<String, dynamic>>();

    return data.map((it) => Message.fromJson(it)).toList();
  }
}

class UpdateMessageStatusRequest extends IApiRequest<Unit> {
  final int roomId;
  final int lastReadId;
  final int lastDeliveredId;

  UpdateMessageStatusRequest({
    @required this.roomId,
    this.lastReadId,
    this.lastDeliveredId,
  });

  get url => 'update_comment_status';
  get method => IRequestMethod.post;
  get body => <String, dynamic>{
        'room_id': roomId.toString(),
        'last_comment_read_id': lastReadId?.toString(),
        'last_comment_received_id': lastDeliveredId?.toString(),
      };

  format(json) {
    return unit;
  }
}

UpdateMessageStatusRequest markMessageAsRead({
  @required int roomId,
  @required int messageId,
}) {
  return UpdateMessageStatusRequest(
    roomId: roomId,
    lastReadId: messageId,
  );
}

UpdateMessageStatusRequest markMessageAsDelivered({
  @required int roomId,
  @required int messageId,
}) {
  return UpdateMessageStatusRequest(
    roomId: roomId,
    lastDeliveredId: messageId,
  );
}

class DeleteMessagesRequest extends IApiRequest<List<Message>> {
  final List<String> uniqueIds;
  final bool isHardDelete;
  final bool isForEveryone;
  DeleteMessagesRequest({
    @required this.uniqueIds,
    this.isForEveryone = true,
    this.isHardDelete = true,
  });

  get url => 'delete_messages';
  get method => IRequestMethod.delete;
  get params => <String, dynamic>{
        'unique_ids': uniqueIds,
        'is_hard_delete': isHardDelete,
        'is_delete_for_everyone': isForEveryone,
      };
  format(json) {
    var data = (json['results']['comments'] as List) //
        .cast<Map<String, dynamic>>();

    return data.map((m) => Message.fromJson(m)).toList();
  }
}
