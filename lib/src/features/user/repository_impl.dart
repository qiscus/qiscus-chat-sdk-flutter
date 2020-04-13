import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/account.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/user.dart';
import 'package:qiscus_chat_sdk/src/features/user/repository.dart';
import 'package:qiscus_chat_sdk/src/features/user/user_api.dart';

class UserRepositoryImpl implements UserRepository {
  final UserApi _api;

  UserRepositoryImpl(this._api);

  @override
  Task<Either<Exception, AuthenticateResponse>> authenticate({
    String userId,
    String userKey,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  }) {
    return Task(() => _api.authenticate(
          AuthenticateRequest(
            userId,
            userKey,
            username: name,
            avatar_url: avatarUrl,
            extras: extras,
          ),
        )).attempt().leftMapToException();
  }

  @override
  Task<Either<Exception, AuthenticateResponse>> authenticateWithToken({
    String identityToken,
  }) {
    return Task(() => _api.authenticateWithToken(
          AuthenticateWithTokenRequest(identityToken),
        )).attempt().leftMapToException().rightMap((res) => res);
  }

  @override
  Task<Either<Exception, User>> blockUser({String userId}) {
    return Task(() => _api.blockUser(BlockUserRequest(userId)))
        .attempt()
        .leftMapToException();
  }

  @override
  Task<Either<Exception, List<User>>> getBlockedUser({int page, int limit}) {
    return Task(() => _api.getBlockedUsers(page: page, limit: limit))
        .attempt()
        .leftMapToException();
  }

  @override
  Task<Either<Exception, String>> getNonce() {
    return Task(_api.getNonce).attempt().leftMapToException().rightMap((res) {
      return res.nonce;
    });
  }

  @override
  Task<Either<Exception, Account>> getUserData() {
    return Task(_api.getUserData)
        .attempt()
        .leftMapToException()
        .rightMap((res) => res.user);
  }

  @override
  Task<Either<Exception, List<User>>> getUsers({
    @Deprecated('will be removed on next release') String query,
    int page,
    int limit,
  }) {
    return Task(() => _api.getUsers(query: query, page: page, limit: limit))
        .attempt()
        .leftMapToException()
        .rightMap((resp) => resp.users);
  }

  @override
  Task<Either<Exception, bool>> registerDeviceToken({
    String token,
    bool isDevelopment,
  }) {
    return Task(() => _api.registerDeviceToken(
          DeviceTokenRequest(
            token,
            isDevelopment,
          ),
        )).attempt().leftMapToException().rightMap((str) {
      var json = jsonDecode(str) as Map<String, dynamic>;
      var changed = json['results']['changed'];
      return changed;
    });
  }

  @override
  Task<Either<Exception, User>> unblockUser({String userId}) {
    return Task(() => _api.unblockUser(BlockUserRequest(userId)))
        .attempt()
        .leftMapToException();
  }

  @override
  Task<Either<Exception, bool>> unregisterDeviceToken({
    String token,
    bool isDevelopment,
  }) {
    return Task(() => _api.unregisterDeviceToken(DeviceTokenRequest(
          token,
          isDevelopment,
        ))).attempt().leftMapToException().rightMap((str) {
      var json = jsonDecode(str) as Map<String, dynamic>;
      var changed = json['results']['changed'];
      return changed;
    });
  }

  @override
  Task<Either<Exception, Account>> updateUser({
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  }) {
    return Task(() => _api.updateUser(
          UpdateUserRequest(
            name: name,
            avatar_url: avatarUrl,
            extras: extras,
          ),
        )).attempt().leftMapToException();
  }
}
