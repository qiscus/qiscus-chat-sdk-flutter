part of qiscus_chat_sdk.usecase.message;

class MessageRepositoryImpl implements MessageRepository {
  MessageRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<Message>> getMessages(
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
    return _dio.sendApiRequest(request).then(request.format);
  }

  @override
  Future<Message> sendMessage(
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
    return _dio.sendApiRequest(request).then(request.format);
  }

  @override
  Future<void> updateStatus({
    @required int roomId,
    int readId = 0,
    int deliveredId = 0,
  }) {
    var request = UpdateMessageStatusRequest(
      roomId: roomId,
      lastDeliveredId: deliveredId,
      lastReadId: readId,
    );
    return _dio.sendApiRequest(request).then(request.format);
  }

  @override
  Future<Message> updateMessage({@required QMessage message}) {
    var request = UpdateMessageRequest(message: message);
    return _dio.sendApiRequest(request).then(request.format);
  }

  @override
  Future<List<Message>> deleteMessages({
    @required List<String> uniqueIds,
    bool isForEveryone = true,
    bool isHard = true,
  }) {
    var request = DeleteMessagesRequest(
      uniqueIds: uniqueIds,
      isForEveryone: isForEveryone,
      isHardDelete: isHard,
    );
    return _dio.sendApiRequest(request).then(request.format);
  }

  @override
  Future<Iterable<QMessage>> getFileList({
    String query,
    String userId,
    List<int> roomIds,
    String fileType,
    List<String> includeExtensions,
    List<String> excludeExtensions,
    int page,
    int limit,
  }) {
    var request = FileListRequest(
      query: query,
      sender: userId,
      roomIds: roomIds,
      fileType: fileType,
      includeExtensions: includeExtensions,
      excludeExtensions: excludeExtensions,
      page: page,
      limit: limit,
    );
    return request.call(_dio);
  }
}
