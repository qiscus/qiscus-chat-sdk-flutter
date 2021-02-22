part of qiscus_chat_sdk.usecase.message;

abstract class MessageRepository {
  Future<Either<QError, Message>> sendMessage(
    int roomId,
    String message, {
    String type = 'text',
    String uniqueId,
    Map<String, dynamic> extras,
    Map<String, dynamic> payload,
  });

  Future<Either<QError, List<Message>>> getMessages(
    int roomId,
    int lastMessageId, {
    bool after,
    int limit,
  });

  Future<Either<QError, void>> updateStatus({
    int roomId,
    int readId,
    int deliveredId,
  });

  Future<Either<QError, Message>> updateMessage({@required QMessage message});

  Future<Either<QError, List<Message>>> deleteMessages({
    @required List<String> uniqueIds,
    bool isForEveryone = true,
    bool isHard = true,
  });
}
