import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/api_request.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/core/utils.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/account.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/user.dart';
import 'package:qiscus_chat_sdk/src/features/user/repository.dart';

import 'user_api_request.dart' as r;

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
      var request = r.AuthenticateRequest(
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
      var request = r.AuthenticateWithTokenRequest(
        identityToken: identityToken,
      );
      return dio.sendApiRequest(request).then(request.format);
    });
  }

  @override
  Task<Either<QError, User>> blockUser({@required String userId}) {
    return task(() async {
      var request = r.BlockUserRequest(userId: userId);
      return dio.sendApiRequest(request).then(request.format);
    });
  }

  @override
  Task<Either<QError, List<User>>> getBlockedUser({int page, int limit}) {
    return task(() async {
      var request = r.GetBlockedUsersRequest(page: page, limit: limit);
      return dio.sendApiRequest(request).then(request.format);
    });
  }

  @override
  Task<Either<QError, String>> getNonce() {
    return task(() async {
      var request = r.GetNonceRequest();
      return dio.sendApiRequest(request).then(request.format);
    });
  }

  @override
  Task<Either<QError, Account>> getUserData() {
    return task(() async {
      var request = r.GetUserDataRequest();
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
      var request = r.GetUserListRequest(
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
      var request = r.SetDeviceTokenRequest(
        token: token,
        isDevelopment: isDevelopment,
      );
      return dio.sendApiRequest(request).then(request.format);
    });
  }

  @override
  Task<Either<QError, User>> unblockUser({String userId}) {
    return task(() async {
      var request = r.UnblockUserRequest(userId: userId);
      return dio.sendApiRequest(request).then(request.format);
    });
  }

  @override
  Task<Either<QError, bool>> unregisterDeviceToken({
    String token,
    bool isDevelopment,
  }) {
    return task(() async {
      var request = r.UnsetDeviceTokenRequest(
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
      var request = r.UpdateUserDataRequest(
        name: name,
        avatarUrl: avatarUrl,
        extras: extras,
      );

      return dio.sendApiRequest(request).then(request.format);
    });
  }
}
