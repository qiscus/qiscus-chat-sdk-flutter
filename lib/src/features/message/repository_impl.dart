part of qiscus_chat_sdk.usecase.message;

class MessageRepositoryImpl implements MessageRepository {
  MessageRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Either<QError, List<Message>>> getMessages(
    int roomId,
    int lastMessageId, {
    bool after = false,
    int limit = 20,
  }) async {
    var request = GetMessagesRequest(
      roomId: roomId,
      lastMessageId: lastMessageId,
      after: after,
      limit: limit,
    );
    return _dio.sendApiRequest(request).then(request.format).toEither();
  }

  @override
  Future<Either<QError, Message>> sendMessage(
    int roomId,
    String message, {
    String type = 'text',
    String uniqueId,
    Map<String, dynamic> extras,
    Map<String, dynamic> payload,
  }) async {
    var request = SendMessageRequest(
      roomId: roomId,
      message: message,
      type: type,
      uniqueId: uniqueId,
      extras: extras,
      payload: payload,
    );
    return _dio.sendApiRequest(request).then(request.format).toEither();
  }

  @override
  Future<Either<QError, void>> updateStatus({
    @required int roomId,
    int readId = 0,
    int deliveredId = 0,
  }) {
    var request = UpdateMessageStatusRequest(
      roomId: roomId,
      lastDeliveredId: deliveredId,
      lastReadId: readId,
    );
    return _dio.sendApiRequest(request).then(request.format).toEither();
  }

  Future<Either<QError, Message>> updateMessage({@required QMessage message}) {
    var request = UpdateMessageRequest(message: message);
    return _dio.sendApiRequest(request).then(request.format).toEither();
  }

  @override
  Future<Either<QError, List<Message>>> deleteMessages({
    @required List<String> uniqueIds,
    bool isForEveryone = true,
    bool isHard = true,
  }) {
    var request = DeleteMessagesRequest(
      uniqueIds: uniqueIds,
      isForEveryone: isForEveryone,
      isHardDelete: isHard,
    );
    return _dio.sendApiRequest(request).then(request.format).toEither();
  }
}
