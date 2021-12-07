import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/message/message-model.dart';
import 'package:qiscus_chat_sdk/src/impls/message/message-from-json-impl.dart';

ReaderTaskEither<Dio, String, Iterable<QMessage>> getNextMessagesImpl(
  int roomId,
  int messageId, {
  int? limit,
}) {
  return Reader((dio) {
    return tryCatch(() async {
      var req = GetMessagesRequest(
        roomId: roomId,
        lastMessageId: messageId,
        limit: limit,
        after: true,
      );

      return req(dio);
    });
  });
}

ReaderTaskEither<Dio, String, Iterable<QMessage>> getPreviousMessagesImpl(
  int roomId,
  int messageId, {
  int? limit,
}) {
  return Reader((dio) {
    return tryCatch(() async {
      return GetMessagesRequest(
        roomId: roomId,
        lastMessageId: messageId,
        limit: limit,
      )(dio);
    });
  });
}

class GetMessagesRequest extends IApiRequest<Iterable<QMessage>> {
  final int roomId;
  final int lastMessageId;
  final int? limit;
  final bool? after;

  GetMessagesRequest({
    required this.roomId,
    required this.lastMessageId,
    this.after = false,
    this.limit = 20,
  });

  @override
  String get url => 'load_comments';
  @override
  IRequestMethod get method => IRequestMethod.get;
  @override
  Map<String, dynamic> get params => <String, dynamic>{
        'topic_id': roomId,
        'last_comment_id': lastMessageId,
        'after': after,
        'limit': limit,
      };

  @override
  Iterable<QMessage> format(Map<String, dynamic> json) sync* {
    var data = (json['results']['comments'] as List) //
        .cast<Map<String, dynamic>>();

    for (var json in data) {
      yield messageFromJson(json);
    }
  }
}
