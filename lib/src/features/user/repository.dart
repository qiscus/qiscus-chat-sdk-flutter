library qiscus_chat_sdk.domain.user_repository;

import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/account.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/user.dart';
import 'package:qiscus_chat_sdk/src/features/user/user_api.dart';

abstract class IUserRepository {
  Task<Either<Exception, AuthenticateResponse>> authenticate({
    @required String userId,
    @required String userKey,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  });

  Task<Either<Exception, AuthenticateResponse>> authenticateWithToken({
    @required String identityToken,
  });

  Task<Either<Exception, User>> blockUser({@required String userId});

  Task<Either<Exception, List<User>>> getBlockedUser({
    int page,
    int limit,
  });

  Task<Either<Exception, String>> getNonce();

  Task<Either<Exception, Account>> getUserData();

  Task<Either<Exception, List<User>>> getUsers({
    String query,
    int page,
    int limit,
  });

  Task<Either<Exception, bool>> registerDeviceToken({
    @required String token,
    bool isDevelopment,
  });

  Task<Either<Exception, User>> unblockUser({@required String userId});

  Task<Either<Exception, bool>> unregisterDeviceToken({
    @required String token,
    bool isDevelopment,
  });

  Task<Either<Exception, Account>> updateUser({
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  });
}
