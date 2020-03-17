import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/features/message/entity.dart';

abstract class MessageRepository {
  Task<Either<Exception, SendMessageResponse>> sendMessage(
    int roomId,
    String message, {
    String type = 'text',
    String uniqueId,
    Map<String, dynamic> extras,
  });

  Task<Either<Exception, GetMessageListResponse>> getMessages(
    int roomId,
    int lastMessageId, {
    bool after,
    int limit,
  });

  Task<Either<Exception, Unit>> updateStatus({
    int roomId,
    int readId,
    int deliveredId,
  });
}

class GetMessageListResponse {
  const GetMessageListResponse(this.messages);

  final List<Map<String, dynamic>> messages;
}

class SendMessageResponse {
  const SendMessageResponse(this.comment);
  final Map<String, dynamic> comment;
}
