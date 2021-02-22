part of qiscus_chat_sdk.usecase.room;

abstract class IRoomRepository {
  Future<Either<QError, ChatRoom>> getRoomWithUserId({
    @required String userId,
    Map<String, dynamic> extras,
  });

  Future<Either<QError, Tuple2<ChatRoom, List<Message>>>> getRoomWithId(
      int roomId);

  Future<Either<QError, List<Participant>>> addParticipant(
    int roomId,
    List<String> participantIds,
  );

  Future<Either<QError, List<String>>> removeParticipant(
    int roomId,
    List<String> participantIds,
  );

  Future<Either<QError, List<Participant>>> getParticipants(
    String uniqueId, {
    int page,
    int limit,
    String sorting,
  });

  Future<Either<QError, List<ChatRoom>>> getAllRooms({
    bool withParticipants,
    bool withEmptyRoom,
    bool withRemovedRoom,
    int limit,
    int page,
  });

  Future<Either<QError, ChatRoom>> getOrCreateChannel({
    @required String uniqueId,
    String name,
    String avatarUrl,
    Map<String, dynamic> options,
  });

  Future<Either<QError, ChatRoom>> createGroup({
    @required String name,
    @required List<String> userIds,
    String avatarUrl,
    Map<String, dynamic> extras,
  });

  Future<Either<QError, void>> clearMessages({
    @required List<String> uniqueIds,
  });

  Future<Either<QError, List<ChatRoom>>> getRoomInfo({
    List<int> roomIds,
    List<String> uniqueIds,
    bool withParticipants,
    bool withRemoved,
    int page,
  });

  Future<Either<QError, int>> getTotalUnreadCount();

  Future<Either<QError, ChatRoom>> updateRoom({
    @required int roomId,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  });
}
