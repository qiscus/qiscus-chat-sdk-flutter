import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/api_request.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/core/utils.dart';

import 'entity.dart';
import 'message_api_request.dart';
import 'repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  MessageRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Task<Either<QError, List<Message>>> getMessages(
    int roomId,
    int lastMessageId, {
    bool after = false,
    int limit = 20,
  }) {
    return task(() async {
      var request = GetMessagesRequest(
        roomId: roomId,
        lastMessageId: lastMessageId,
        after: after,
        limit: limit,
      );
      return _dio.sendApiRequest(request).then((r) => request.format(r));
    });
  }

  @override
  Task<Either<QError, Message>> sendMessage(
    int roomId,
    String message, {
    String type = 'text',
    String uniqueId,
    Map<String, dynamic> extras,
    Map<String, dynamic> payload,
  }) {
    return task(() async {
      var request = SendMessageRequest(
        roomId: roomId,
        message: message,
        type: type,
        uniqueId: uniqueId,
        extras: extras,
        payload: payload,
      );
      return _dio.sendApiRequest(request).then((r) => request.format(r));
    });
  }

  @override
  Task<Either<QError, Unit>> updateStatus({
    @required int roomId,
    int readId = 0,
    int deliveredId = 0,
  }) {
    return task(() async {
      var request = UpdateMessageStatusRequest(
        roomId: roomId,
        lastDeliveredId: deliveredId,
        lastReadId: readId,
      );
      return _dio.sendApiRequest(request).then((r) => request.format(r));
    });
  }

  @override
  Task<Either<QError, List<Message>>> deleteMessages({
    @required List<String> uniqueIds,
    bool isForEveryone = true,
    bool isHard = true,
  }) {
    return task(() async {
      var request = DeleteMessagesRequest(
        uniqueIds: uniqueIds,
        isForEveryone: isForEveryone,
        isHardDelete: isHard,
      );
      return _dio.sendApiRequest(request).then((r) => request.format(r));
    });
  }
}
