part of qiscus_chat_sdk.usecase.room;

abstract class IRoomRepository {
  Future<ChatRoom> getRoomWithUserId({
    @required String userId,
    Map<String, dynamic> extras,
  });

  Future<Tuple2<ChatRoom, List<Message>>> getRoomWithId(int roomId);

  Future<List<Participant>> addParticipant(
    int roomId,
    List<String> participantIds,
  );

  Future<List<String>> removeParticipant(
    int roomId,
    List<String> participantIds,
  );

  Future<List<Participant>> getParticipants(
    String uniqueId, {
    int page,
    int limit,
    String sorting,
  });

  Future<List<ChatRoom>> getAllRooms({
    bool withParticipants,
    bool withEmptyRoom,
    bool withRemovedRoom,
    int limit,
    int page,
  });

  Future<ChatRoom> getOrCreateChannel({
    @required String uniqueId,
    String name,
    String avatarUrl,
    Map<String, dynamic> options,
  });

  Future<ChatRoom> createGroup({
    @required String name,
    @required List<String> userIds,
    String avatarUrl,
    Map<String, dynamic> extras,
  });

  Future<void> clearMessages({
    @required List<String> uniqueIds,
  });

  Future<List<ChatRoom>> getRoomInfo({
    List<int> roomIds,
    List<String> uniqueIds,
    bool withParticipants,
    bool withRemoved,
    int page,
  });

  Future<int> getTotalUnreadCount();

  Future<ChatRoom> updateRoom({
    @required int roomId,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  });
}
