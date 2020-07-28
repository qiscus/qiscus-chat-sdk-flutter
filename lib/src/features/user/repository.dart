library qiscus_chat_sdk.domain.user_repository;

import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/account.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/user.dart';

abstract class IUserRepository {
  Task<Either<QError, Tuple2<String, Account>>> authenticate({
    @required String userId,
    @required String userKey,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  });

  Task<Either<QError, Tuple2<String, Account>>> authenticateWithToken({
    @required String identityToken,
  });

  Task<Either<QError, User>> blockUser({@required String userId});

  Task<Either<QError, List<User>>> getBlockedUser({
    int page,
    int limit,
  });

  Task<Either<QError, String>> getNonce();

  Task<Either<QError, Account>> getUserData();

  Task<Either<QError, List<User>>> getUsers({
    String query,
    int page,
    int limit,
  });

  Task<Either<QError, bool>> registerDeviceToken({
    @required String token,
    bool isDevelopment,
  });

  Task<Either<QError, User>> unblockUser({@required String userId});

  Task<Either<QError, bool>> unregisterDeviceToken({
    @required String token,
    bool isDevelopment,
  });

  Task<Either<QError, Account>> updateUser({
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  });
}
