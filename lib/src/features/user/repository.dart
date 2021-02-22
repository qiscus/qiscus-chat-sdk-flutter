part of qiscus_chat_sdk.usecase.user;

abstract class IUserRepository {
  Future<Either<QError, Tuple2<String, Account>>> authenticate({
    @required String userId,
    @required String userKey,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  });

  Future<Either<QError, Tuple2<String, Account>>> authenticateWithToken({
    @required String identityToken,
  });

  Future<Either<QError, User>> blockUser({@required String userId});

  Future<Either<QError, List<User>>> getBlockedUser({
    int page,
    int limit,
  });

  Future<Either<QError, String>> getNonce();

  Future<Either<QError, Account>> getUserData();

  Future<Either<QError, List<User>>> getUsers({
    String query,
    int page,
    int limit,
  });

  Future<Either<QError, bool>> registerDeviceToken({
    @required String token,
    bool isDevelopment,
  });

  Future<Either<QError, User>> unblockUser({@required String userId});

  Future<Either<QError, bool>> unregisterDeviceToken({
    @required String token,
    bool isDevelopment,
  });

  Future<Either<QError, Account>> updateUser({
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  });
}
