part of qiscus_chat_sdk.usecase.user;

abstract class IUserRepository {
  Future<Tuple2<String, Account>> authenticate({
    @required String userId,
    @required String userKey,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  });

  Future<Tuple2<String, Account>> authenticateWithToken({
    @required String identityToken,
  });

  Future<User> blockUser({@required String userId});

  Future<List<User>> getBlockedUser({
    int page,
    int limit,
  });

  Future<String> getNonce();

  Future<Account> getUserData();

  Future<List<User>> getUsers({
    String query,
    int page,
    int limit,
  });

  Future<bool> registerDeviceToken({
    @required String token,
    bool isDevelopment,
  });

  Future<User> unblockUser({@required String userId});

  Future<bool> unregisterDeviceToken({
    @required String token,
    bool isDevelopment,
  });

  Future<Account> updateUser({
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  });
}
