part of qiscus_chat_sdk.usecase.message;

abstract class MessageRepository {
  Future<Message> sendMessage(
    int roomId,
    String message, {
    String type = 'text',
    String uniqueId,
    Map<String, dynamic> extras,
    Map<String, dynamic> payload,
  });

  Future<List<Message>> getMessages(
    int roomId,
    int lastMessageId, {
    bool after,
    int limit,
  });

  Future<void> updateStatus({
    int roomId,
    int readId,
    int deliveredId,
  });

  Future<Message> updateMessage({@required QMessage message});

  Future<List<Message>> deleteMessages({
    @required List<String> uniqueIds,
    bool isForEveryone = true,
    bool isHard = true,
  });
}
