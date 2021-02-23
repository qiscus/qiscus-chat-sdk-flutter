part of qiscus_chat_sdk.usecase.message;

abstract class MessageRepository {
  Future<Either<Error, Message>> sendMessage(
    int roomId,
    String message, {
    String type = 'text',
    String uniqueId,
    Map<String, dynamic> extras,
    Map<String, dynamic> payload,
  });

  Future<Either<Error, List<Message>>> getMessages(
    int roomId,
    int lastMessageId, {
    bool after,
    int limit,
  });

  Future<Either<Error, void>> updateStatus({
    int roomId,
    int readId,
    int deliveredId,
  });

  Future<Either<Error, Message>> updateMessage({@required QMessage message});

  Future<Either<Error, List<Message>>> deleteMessages({
    @required List<String> uniqueIds,
    bool isForEveryone = true,
    bool isHard = true,
  });
}
