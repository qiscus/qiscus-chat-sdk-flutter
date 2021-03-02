part of qiscus_chat_sdk.usecase.user;

class UserRepositoryImpl implements IUserRepository {
  final Dio dio;

  UserRepositoryImpl(this.dio);

  @override
  Future<Tuple2<String, Account>> authenticate({
    String userId,
    String userKey,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  }) async {
    var request = AuthenticateRequest(
      userId: userId,
      userKey: userKey,
      name: name,
      avatarUrl: avatarUrl,
      extras: extras,
    );

    return dio.sendApiRequest(request).then(request.format);
  }

  @override
  Future<Tuple2<String, Account>> authenticateWithToken({
    String identityToken,
  }) async {
    var request = AuthenticateWithTokenRequest(
      identityToken: identityToken,
    );
    return dio.sendApiRequest(request).then(request.format);
  }

  @override
  Future<User> blockUser({@required String userId}) {
    var request = BlockUserRequest(userId: userId);
    return dio.sendApiRequest(request).then(request.format);
  }

  @override
  Future<List<User>> getBlockedUser({int page, int limit}) {
    var request = GetBlockedUsersRequest(page: page, limit: limit);
    return dio.sendApiRequest(request).then(request.format);
  }

  @override
  Future<String> getNonce() {
    var request = GetNonceRequest();
    return dio.sendApiRequest(request).then(request.format);
  }

  @override
  Future<Account> getUserData() {
    var request = GetUserDataRequest();
    return dio.sendApiRequest(request).then(request.format);
  }

  @override
  Future<List<User>> getUsers({
    @Deprecated('will be removed on next release') String query,
    int page,
    int limit,
  }) {
    var request = GetUserListRequest(
      query: query,
      page: page,
      limit: limit,
    );
    return dio.sendApiRequest(request).then(request.format);
  }

  @override
  Future<bool> registerDeviceToken({
    String token,
    bool isDevelopment,
  }) {
    var request = SetDeviceTokenRequest(
      token: token,
      isDevelopment: isDevelopment,
    );
    return dio.sendApiRequest(request).then(request.format);
  }

  @override
  Future<User> unblockUser({String userId}) {
    var request = UnblockUserRequest(userId: userId);
    return dio.sendApiRequest(request).then(request.format);
  }

  @override
  Future<bool> unregisterDeviceToken({
    String token,
    bool isDevelopment,
  }) {
    var request = UnsetDeviceTokenRequest(
      token: token,
      isDevelopment: isDevelopment,
    );
    return dio.sendApiRequest(request).then(request.format);
  }

  @override
  Future<Account> updateUser({
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  }) {
    var request = UpdateUserDataRequest(
      name: name,
      avatarUrl: avatarUrl,
      extras: extras,
    );

    return dio.sendApiRequest(request).then(request.format);
  }
}
