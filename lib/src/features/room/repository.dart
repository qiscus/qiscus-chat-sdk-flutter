part of qiscus_chat_sdk.usecase.room;

abstract class IRoomRepository {
  Future<Either<Error, ChatRoom>> getRoomWithUserId({
    @required String userId,
    Map<String, dynamic> extras,
  });

  Future<Either<Error, Tuple2<ChatRoom, List<Message>>>> getRoomWithId(
      int roomId);

  Future<Either<Error, List<Participant>>> addParticipant(
    int roomId,
    List<String> participantIds,
  );

  Future<Either<Error, List<String>>> removeParticipant(
    int roomId,
    List<String> participantIds,
  );

  Future<Either<Error, List<Participant>>> getParticipants(
    String uniqueId, {
    int page,
    int limit,
    String sorting,
  });

  Future<Either<Error, List<ChatRoom>>> getAllRooms({
    bool withParticipants,
    bool withEmptyRoom,
    bool withRemovedRoom,
    int limit,
    int page,
  });

  Future<Either<Error, ChatRoom>> getOrCreateChannel({
    @required String uniqueId,
    String name,
    String avatarUrl,
    Map<String, dynamic> options,
  });

  Future<Either<Error, ChatRoom>> createGroup({
    @required String name,
    @required List<String> userIds,
    String avatarUrl,
    Map<String, dynamic> extras,
  });

  Future<Either<Error, void>> clearMessages({
    @required List<String> uniqueIds,
  });

  Future<Either<Error, List<ChatRoom>>> getRoomInfo({
    List<int> roomIds,
    List<String> uniqueIds,
    bool withParticipants,
    bool withRemoved,
    int page,
  });

  Future<Either<Error, int>> getTotalUnreadCount();

  Future<Either<Error, ChatRoom>> updateRoom({
    @required int roomId,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  });
}
