import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/account.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/user.dart';
import 'package:qiscus_chat_sdk/src/features/user/repository.dart';
import 'package:qiscus_chat_sdk/src/features/user/user_api.dart';

class UserRepositoryImpl implements IUserRepository {
  final UserApi _api;

  UserRepositoryImpl(this._api);

  @override
  Task<Either<QError, AuthenticateResponse>> authenticate({
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
        )).attempt().leftMapToQError();
  }

  @override
  Task<Either<QError, AuthenticateResponse>> authenticateWithToken({
    String identityToken,
  }) {
    return Task(() => _api.authenticateWithToken(
          AuthenticateWithTokenRequest(identityToken),
        )).attempt().leftMapToQError().rightMap((res) => res);
  }

  @override
  Task<Either<QError, User>> blockUser({String userId}) {
    return Task(() => _api.blockUser(BlockUserRequest(userId)))
        .attempt()
        .leftMapToQError();
  }

  @override
  Task<Either<QError, List<User>>> getBlockedUser({int page, int limit}) {
    return Task(() => _api.getBlockedUsers(page: page, limit: limit))
        .attempt()
        .leftMapToQError();
  }

  @override
  Task<Either<QError, String>> getNonce() {
    return Task(_api.getNonce).attempt().leftMapToQError().rightMap((res) {
      return res.nonce;
    });
  }

  @override
  Task<Either<QError, Account>> getUserData() {
    return Task(_api.getUserData)
        .attempt()
        .leftMapToQError()
        .rightMap((res) => res.user);
  }

  @override
  Task<Either<QError, List<User>>> getUsers({
    @Deprecated('will be removed on next release') String query,
    int page,
    int limit,
  }) {
    return Task(() => _api.getUsers(query: query, page: page, limit: limit))
        .attempt()
        .leftMapToQError()
        .rightMap((resp) => resp.users);
  }

  @override
  Task<Either<QError, bool>> registerDeviceToken({
    String token,
    bool isDevelopment,
  }) {
    return Task(() => _api.registerDeviceToken(
          DeviceTokenRequest(
            token,
            isDevelopment,
          ),
        )).attempt().leftMapToQError().rightMap((str) {
      if (str.isEmpty) return true;
      var json = jsonDecode(str) as Map<String, dynamic>;
      var changed = json['results']['changed'] as bool;
      return changed;
    });
  }

  @override
  Task<Either<QError, User>> unblockUser({String userId}) {
    return Task(() => _api.unblockUser(BlockUserRequest(userId)))
        .attempt()
        .leftMapToQError();
  }

  @override
  Task<Either<QError, bool>> unregisterDeviceToken({
    String token,
    bool isDevelopment,
  }) {
    return Task(() => _api.unregisterDeviceToken(DeviceTokenRequest(
          token,
          isDevelopment,
        ))).attempt().leftMapToQError().rightMap((str) {
      var json = jsonDecode(str) as Map<String, dynamic>;
      var changed = json['results']['changed'] as bool;
      return changed ?? true;
    });
  }

  @override
  Task<Either<QError, Account>> updateUser({
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  }) {
    return Task(() => _api.updateUser(
          UpdateUserRequest(
            name: name,
            avatarUrl: avatarUrl,
            extras: extras,
          ),
        )).attempt().leftMapToQError().rightMap((String str) {
      var json = jsonDecode(str) as Map<String, dynamic>;
      var userJson = json['results']['user'] as Map<String, dynamic>;
      return Account.fromJson(userJson);
    });
  }
}
