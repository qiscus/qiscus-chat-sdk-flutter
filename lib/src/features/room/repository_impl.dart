part of qiscus_chat_sdk.usecase.room;

class RoomRepositoryImpl implements IRoomRepository {
  final Dio dio;
  final Storage storage;

  const RoomRepositoryImpl({
    @required this.dio,
    @required this.storage,
  });

  @override
  Task<Either<QError, ChatRoom>> getRoomWithUserId({
    @required String userId,
    Map<String, dynamic> extras,
  }) {
    return storage.authenticated$.andThen(task(() async {
      var request = ChatTargetRequest(
        userId: userId,
        extras: extras,
      );
      return dio.sendApiRequest(request).then(request.format);
    }));
  }

  @override
  Task<Either<QError, Tuple2<ChatRoom, List<Message>>>> getRoomWithId(
      int roomId) {
    return storage.authenticated$.andThen(task(() async {
      var request = GetRoomByIdRequest(roomId: roomId);
      return dio.sendApiRequest(request).then(request.format);
    }));
  }

  @override
  Task<Either<QError, List<Participant>>> addParticipant(
    int roomId,
    List<String> participantIds,
  ) {
    return storage.authenticated$.andThen(task(() async {
      var request = AddParticipantRequest(
        roomId: roomId,
        userIds: participantIds,
      );
      return dio.sendApiRequest(request).then(request.format);
    }));
  }

  @override
  Task<Either<QError, List<String>>> removeParticipant(
    int roomId,
    List<String> participantIds,
  ) {
    return storage.authenticated$.andThen(task(() async {
      var request = RemoveParticipantRequest(
        roomId: roomId,
        userIds: participantIds,
      );
      return dio.sendApiRequest(request).then(request.format);
    }));
  }

  @override
  Task<Either<QError, List<Participant>>> getParticipants(
    String uniqueId, {
    int page,
    int limit,
    String sorting,
  }) {
    return storage.authenticated$.andThen(task(() async {
      var request = GetParticipantRequest(
        roomUniqueId: uniqueId,
        page: page,
        limit: limit,
        sorting: sorting,
      );
      return dio.sendApiRequest(request).then(request.format);
    }));
  }

  @override
  Task<Either<QError, List<ChatRoom>>> getAllRooms({
    bool withParticipants,
    bool withEmptyRoom,
    bool withRemovedRoom,
    int limit,
    int page,
  }) {
    return storage.authenticated$.andThen(task(() async {
      var request = GetAllRoomRequest(
        withParticipants: withParticipants,
        withEmptyRoom: withEmptyRoom,
        withRemovedRoom: withRemovedRoom,
        limit: limit,
        page: page,
      );

      return dio
          .sendApiRequest(request) //
          .then(request.format);
    }));
  }

  @override
  Task<Either<QError, ChatRoom>> getOrCreateChannel({
    String uniqueId,
    String name,
    String avatarUrl,
    Map<String, dynamic> options,
  }) {
    return storage.authenticated$.andThen(task(() async {
      var request = GetOrCreateChannelRequest(
        uniqueId: uniqueId,
        name: name,
        avatarUrl: avatarUrl,
        extras: options,
      );
      return dio.sendApiRequest(request).then(request.format);
    }));
  }

  @override
  Task<Either<QError, ChatRoom>> createGroup({
    String name,
    List<String> userIds,
    String avatarUrl,
    Map<String, dynamic> extras,
  }) {
    return storage.authenticated$.andThen(task(() async {
      var request = CreateGroupRequest(
        name: name,
        userIds: userIds,
        avatarUrl: avatarUrl,
        extras: extras,
      );
      return dio.sendApiRequest(request).then(request.format);
    }));
  }

  @override
  Task<Either<QError, Unit>> clearMessages({
    @required List<String> uniqueIds,
  }) {
    return storage.authenticated$.andThen(task(() async {
      var request = ClearMessagesRequest(roomUniqueIds: uniqueIds);
      return dio.sendApiRequest(request).then(request.format);
    }));
  }

  @override
  Task<Either<QError, List<ChatRoom>>> getRoomInfo({
    List<int> roomIds,
    List<String> uniqueIds,
    bool withParticipants,
    bool withRemoved,
    int page,
  }) {
    return storage.authenticated$.andThen(task(() async {
      var r = GetRoomInfoRequest(
        roomIds: roomIds,
        uniqueIds: uniqueIds,
        withParticipants: withParticipants,
        withRemoved: withRemoved,
        page: page,
      );
      return dio.sendApiRequest(r).then(r.format);
    }));
  }

  @override
  Task<Either<QError, int>> getTotalUnreadCount() {
    return storage.authenticated$.andThen(task(() async {
      var r = GetTotalUnreadCountRequest();
      return dio.sendApiRequest(r).then(r.format);
    }));
  }

  @override
  Task<Either<QError, ChatRoom>> updateRoom({
    @required int roomId,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  }) {
    return storage.authenticated$.andThen(task(() async {
      var r = UpdateRoomRequest(
        roomId: roomId.toString(),
        name: name,
        avatarUrl: avatarUrl,
        extras: extras,
      );

      return dio.sendApiRequest(r).then(r.format);
    }));
  }
}
