part of qiscus_chat_sdk.usecase.room;

class RoomRepositoryImpl implements IRoomRepository {
  final Dio dio;
  final Storage storage;

  const RoomRepositoryImpl({
    @required this.dio,
    @required this.storage,
  });

  @override
  Future<Either<Error, ChatRoom>> getRoomWithUserId({
    @required String userId,
    Map<String, dynamic> extras,
  }) async {
    await storage.authenticated$;
    var request = ChatTargetRequest(
      userId: userId,
      extras: extras,
    );
    return dio.sendApiRequest(request).then(request.format).toEither();
  }

  @override
  Future<Either<Error, Tuple2<ChatRoom, List<Message>>>> getRoomWithId(
    int roomId,
  ) async {
    await storage.authenticated$;
    var request = GetRoomByIdRequest(roomId: roomId);

    var res = dio
        .sendApiRequest(request)
        .then((data) {
          print('before formatting: ($data)');
          return data;
        })
        .then((data) => request.format(data))
        .then((data) {
          print('after formatting: ($data)');
          return data;
        });

    return res.toEither();
  }

  @override
  Future<Either<Error, List<Participant>>> addParticipant(
    int roomId,
    List<String> participantIds,
  ) async {
    await storage.authenticated$;
    var request = AddParticipantRequest(
      roomId: roomId,
      userIds: participantIds,
    );
    return dio.sendApiRequest(request).then(request.format).toEither();
  }

  @override
  Future<Either<Error, List<String>>> removeParticipant(
    int roomId,
    List<String> participantIds,
  ) async {
    await storage.authenticated$;
    var request = RemoveParticipantRequest(
      roomId: roomId,
      userIds: participantIds,
    );
    return dio.sendApiRequest(request).then(request.format).toEither();
  }

  @override
  Future<Either<Error, List<Participant>>> getParticipants(
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
    return dio.sendApiRequest(request).then(request.format).toEither();
  }

  @override
  Future<Either<Error, List<ChatRoom>>> getAllRooms({
    bool withParticipants,
    bool withEmptyRoom,
    bool withRemovedRoom,
    int limit,
    int page,
  }) async {
    await storage.authenticated$;
    var request = GetAllRoomRequest(
      withParticipants: withParticipants,
      withEmptyRoom: withEmptyRoom,
      withRemovedRoom: withRemovedRoom,
      limit: limit,
      page: page,
    );

    return dio.sendApiRequest(request).then(request.format).toEither();
  }

  @override
  Future<Either<Error, ChatRoom>> getOrCreateChannel({
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
    return dio.sendApiRequest(request).then(request.format).toEither();
  }

  @override
  Future<Either<Error, ChatRoom>> createGroup({
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
    return dio.sendApiRequest(request).then(request.format).toEither();
  }

  @override
  Future<Either<Error, void>> clearMessages({
    @required List<String> uniqueIds,
  }) async {
    await storage.authenticated$;
    var request = ClearMessagesRequest(roomUniqueIds: uniqueIds);
    return dio.sendApiRequest(request).then(request.format).toEither();
  }

  @override
  Future<Either<Error, List<ChatRoom>>> getRoomInfo({
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
    return dio.sendApiRequest(r).then(r.format).toEither();
  }

  @override
  Future<Either<Error, int>> getTotalUnreadCount() async {
    await storage.authenticated$;
    var r = GetTotalUnreadCountRequest();
    return dio.sendApiRequest(r).then(r.format).toEither();
  }

  @override
  Future<Either<Error, ChatRoom>> updateRoom({
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

    return dio.sendApiRequest(r).then(r.format).toEither();
  }
}
