part of qiscus_chat_sdk.usecase.room;

class RoomRepositoryImpl implements IRoomRepository {
  final Dio dio;
  final Storage storage;

  const RoomRepositoryImpl({
    @required this.dio,
    @required this.storage,
  });

  @override
  Future<ChatRoom> getRoomWithUserId({
    @required String userId,
    Map<String, dynamic> extras,
  }) async {
    await storage.authenticated$;
    var request = ChatTargetRequest(
      userId: userId,
      extras: extras,
    );
    return dio.sendApiRequest(request).then(request.format);
  }

  @override
  Future<Tuple2<ChatRoom, List<Message>>> getRoomWithId(
    int roomId,
  ) async {
    await storage.authenticated$;
    var request = GetRoomByIdRequest(roomId: roomId);

    var res = dio.sendApiRequest(request).then((data) => request.format(data));
    return res;
  }

  @override
  Future<List<Participant>> addParticipant(
    int roomId,
    List<String> participantIds,
  ) async {
    await storage.authenticated$;
    var request = AddParticipantRequest(
      roomId: roomId,
      userIds: participantIds,
    );
    return dio.sendApiRequest(request).then(request.format);
  }

  @override
  Future<List<String>> removeParticipant(
    int roomId,
    List<String> participantIds,
  ) async {
    await storage.authenticated$;
    var request = RemoveParticipantRequest(
      roomId: roomId,
      userIds: participantIds,
    );
    return dio.sendApiRequest(request).then(request.format);
  }

  @override
  Future<List<Participant>> getParticipants(
    String uniqueId, {
    int page,
    int limit,
    String sorting,
  }) async {
    await storage.authenticated$;
    var request = GetParticipantRequest(
      roomUniqueId: uniqueId,
      page: page,
      limit: limit,
      sorting: sorting,
    );
    return dio.sendApiRequest(request).then(request.format);
  }

  @override
  Future<List<ChatRoom>> getAllRooms({
    bool withParticipants,
    bool withEmptyRoom,
    bool withRemovedRoom,
    int limit,
    int page,
    QRoomType roomType,
  }) async {
    await storage.authenticated$;
    var request = GetAllRoomRequest(
      withParticipants: withParticipants,
      withEmptyRoom: withEmptyRoom,
      withRemovedRoom: withRemovedRoom,
      limit: limit,
      page: page,
      roomType: roomType,
    );

    return dio.sendApiRequest(request).then(request.format);
  }

  @override
  Future<ChatRoom> getOrCreateChannel({
    String uniqueId,
    String name,
    String avatarUrl,
    Map<String, dynamic> options,
  }) async {
    await storage.authenticated$;
    var request = GetOrCreateChannelRequest(
      uniqueId: uniqueId,
      name: name,
      avatarUrl: avatarUrl,
      extras: options,
    );
    return dio.sendApiRequest(request).then(request.format);
  }

  @override
  Future<ChatRoom> createGroup({
    String name,
    List<String> userIds,
    String avatarUrl,
    Map<String, dynamic> extras,
  }) async {
    await storage.authenticated$;
    var request = CreateGroupRequest(
      name: name,
      userIds: userIds,
      avatarUrl: avatarUrl,
      extras: extras,
    );
    return dio.sendApiRequest(request).then(request.format);
  }

  @override
  Future<void> clearMessages({
    @required List<String> uniqueIds,
  }) async {
    await storage.authenticated$;
    var request = ClearMessagesRequest(roomUniqueIds: uniqueIds);
    return dio.sendApiRequest(request).then(request.format);
  }

  @override
  Future<List<ChatRoom>> getRoomInfo({
    List<int> roomIds,
    List<String> uniqueIds,
    bool withParticipants,
    bool withRemoved,
    int page,
  }) async {
    await storage.authenticated$;
    var r = GetRoomInfoRequest(
      roomIds: roomIds,
      uniqueIds: uniqueIds,
      withParticipants: withParticipants,
      withRemoved: withRemoved,
      page: page,
    );
    return dio.sendApiRequest(r).then(r.format);
  }

  @override
  Future<int> getTotalUnreadCount() async {
    await storage.authenticated$;
    var r = GetTotalUnreadCountRequest();
    return dio.sendApiRequest(r).then(r.format);
  }

  @override
  Future<ChatRoom> updateRoom({
    @required int roomId,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  }) async {
    await storage.authenticated$;
    var r = UpdateRoomRequest(
      roomId: roomId.toString(),
      name: name,
      avatarUrl: avatarUrl,
      extras: extras,
    );

    return dio.sendApiRequest(r).then(r.format);
  }
}
