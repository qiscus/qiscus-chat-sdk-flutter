import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';
import 'package:qiscus_chat_sdk/src/features/message/repository.dart';

import 'api.dart';
import 'entity.dart';

class MessageRepositoryImpl implements MessageRepository {
  MessageRepositoryImpl(this._api);

  final MessageApi _api;

  @override
  Task<Either<Exception, GetMessageListResponse>> getMessages(
    int roomId,
    int lastMessageId, {
    bool after = false,
    int limit = 20,
  }) {
    return Task(
      () => _api.loadComments(
        roomId,
        lastMessageId: lastMessageId,
        limit: limit,
        after: after,
      ),
    ).attempt().leftMapToException().rightMap((str) {
      var json = jsonDecode(str) as Map<String, dynamic>;
      var messages = (json['results']['comments'] as List) //
          .cast<Map<String, dynamic>>();
      return GetMessageListResponse(messages);
    });
  }

  @override
  Task<Either<Exception, SendMessageResponse>> sendMessage(
    int roomId,
    String message, {
    String type = 'text',
    String uniqueId,
    Map<String, dynamic> extras,
    Map<String, dynamic> payload,
  }) {
    return Task(
      () => _api.submitComment(PostCommentRequest(
        roomId: roomId.toString(),
        text: message,
        type: type,
        uniqueId: uniqueId,
        extras: extras,
        payload: payload,
      )),
    ).attempt().leftMapToException().rightMap((str) {
      var json = jsonDecode(str) as Map<String, dynamic>;
      var comment = json['results']['comment'] as Map<String, dynamic>;
      return SendMessageResponse(comment);
    });
  }

  @override
  Task<Either<Exception, Unit>> updateStatus({
    @required int roomId,
    int readId = 0,
    int deliveredId = 0,
  }) {
    return Task(() => _api.updateStatus(UpdateStatusRequest(
          roomId: roomId.toString(),
          lastDeliveredId: deliveredId.toString(),
          lastReadId: readId.toString(),
        ))).attempt().leftMapToException().rightMap((_) => unit);
  }

  @override
  Task<Either<Exception, List<Message>>> deleteMessages({
    @required List<String> uniqueIds,
    bool isForEveryone = true,
    bool isHard = true,
  }) {
    return Task(() => _api.deleteMessages(uniqueIds, isForEveryone, isHard))
        .attempt()
        .leftMapToException()
        .rightMap((res) {
      var json = jsonDecode(res) as Map<String, dynamic>;
      var messages = (json['results']['comments'] as List)
          .cast<Map<String, dynamic>>()
          .map((m) => Message.fromJson(m))
          .toList();
      return messages;
    });
  }
}
