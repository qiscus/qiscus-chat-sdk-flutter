part of qiscus_chat_sdk.usecase.user;

class UserRepositoryImpl implements IUserRepository {
  final Dio dio;

  UserRepositoryImpl(this.dio);

  @override
  Task<Either<QError, Tuple2<String, Account>>> authenticate({
    String userId,
    String userKey,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  }) {
    return task(() async {
      var request = AuthenticateRequest(
        userId: userId,
        userKey: userKey,
        name: name,
        avatarUrl: avatarUrl,
        extras: extras,
      );

      return dio.sendApiRequest(request).then(request.format);
    });
  }

  @override
  Task<Either<QError, Tuple2<String, Account>>> authenticateWithToken({
    String identityToken,
  }) {
    return task(() async {
      var request = AuthenticateWithTokenRequest(
        identityToken: identityToken,
      );
      return dio.sendApiRequest(request).then(request.format);
    });
  }

  @override
  Task<Either<QError, User>> blockUser({@required String userId}) {
    return task(() async {
      var request = BlockUserRequest(userId: userId);
      return dio.sendApiRequest(request).then(request.format);
    });
  }

  @override
  Task<Either<QError, List<User>>> getBlockedUser({int page, int limit}) {
    return task(() async {
      var request = GetBlockedUsersRequest(page: page, limit: limit);
      return dio.sendApiRequest(request).then(request.format);
    });
  }

  @override
  Task<Either<QError, String>> getNonce() {
    return task(() async {
      var request = GetNonceRequest();
      return dio.sendApiRequest(request).then(request.format);
    });
  }

  @override
  Task<Either<QError, Account>> getUserData() {
    return task(() async {
      var request = GetUserDataRequest();
      return dio.sendApiRequest(request).then(request.format);
    });
  }

  @override
  Task<Either<QError, List<User>>> getUsers({
    @Deprecated('will be removed on next release') String query,
    int page,
    int limit,
  }) {
    return task(() async {
      var request = GetUserListRequest(
        query: query,
        page: page,
        limit: limit,
      );
      return dio.sendApiRequest(request).then(request.format);
    });
  }

  @override
  Task<Either<QError, bool>> registerDeviceToken({
    String token,
    bool isDevelopment,
  }) {
    return task(() async {
      var request = SetDeviceTokenRequest(
        token: token,
        isDevelopment: isDevelopment,
      );
      return dio.sendApiRequest(request).then(request.format);
    });
  }

  @override
  Task<Either<QError, User>> unblockUser({String userId}) {
    return task(() async {
      var request = UnblockUserRequest(userId: userId);
      return dio.sendApiRequest(request).then(request.format);
    });
  }

  @override
  Task<Either<QError, bool>> unregisterDeviceToken({
    String token,
    bool isDevelopment,
  }) {
    return task(() async {
      var request = UnsetDeviceTokenRequest(
        token: token,
        isDevelopment: isDevelopment,
      );
      return dio.sendApiRequest(request).then(request.format);
    });
  }

  @override
  Task<Either<QError, Account>> updateUser({
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  }) {
    return task(() async {
      var request = UpdateUserDataRequest(
        name: name,
        avatarUrl: avatarUrl,
        extras: extras,
      );

      return dio.sendApiRequest(request).then(request.format);
    });
  }
}
