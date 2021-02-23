part of qiscus_chat_sdk.usecase.user;

abstract class IUserRepository {
  Future<Either<Error, Tuple2<String, Account>>> authenticate({
    @required String userId,
    @required String userKey,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  });

  Future<Either<Error, Tuple2<String, Account>>> authenticateWithToken({
    @required String identityToken,
  });

  Future<Either<Error, User>> blockUser({@required String userId});

  Future<Either<Error, List<User>>> getBlockedUser({
    int page,
    int limit,
  });

  Future<Either<Error, String>> getNonce();

  Future<Either<Error, Account>> getUserData();

  Future<Either<Error, List<User>>> getUsers({
    String query,
    int page,
    int limit,
  });

  Future<Either<Error, bool>> registerDeviceToken({
    @required String token,
    bool isDevelopment,
  });

  Future<Either<Error, User>> unblockUser({@required String userId});

  Future<Either<Error, bool>> unregisterDeviceToken({
    @required String token,
    bool isDevelopment,
  });

  Future<Either<Error, Account>> updateUser({
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  });
}
