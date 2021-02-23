import 'package:meta/meta.dart';

import 'user-model.dart';

@sealed
abstract class IUserService {
  Future<QUser> authenticate({
    @required String userId,
    @required String userKey,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  });
  Future<QUser> authenticateWithIdentityToken({@required String identityToken});
  Future<bool> block(String userId);
  Future<bool> unblock(String userId);
  Future<Iterable<QUser>> getUsers();
  Future<String> getNonce();
  Future<bool> registerDeviceToken(QDeviceToken token);
  Future<bool> unregisterDeviceToken(QDeviceToken token);
  Future<QUser> update(String id, QUser user);
  Stream<QUserTyping> get onUserTyping;
  Stream<QUserPresence> get onUserPresence;
}

@sealed
class UserService extends IUserService {
  @override
  authenticate({
    String userId,
    String userKey,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  }) async {
    throw UnimplementedError();
  }

  @override
  authenticateWithIdentityToken({String identityToken}) async {
    throw UnimplementedError();
  }

  @override
  block(String userId) {
    throw UnimplementedError();
  }

  @override
  getNonce() {
    throw UnimplementedError();
  }

  @override
  getUsers() {
    throw UnimplementedError();
  }

  @override
  registerDeviceToken(QDeviceToken token) {
    throw UnimplementedError();
  }

  @override
  unblock(String userId) {
    throw UnimplementedError();
  }

  @override
  unregisterDeviceToken(QDeviceToken token) {
    throw UnimplementedError();
  }

  @override
  update(String id, QUser user) {
    throw UnimplementedError();
  }

  @override
  get onUserPresence => throw UnimplementedError();

  @override
  get onUserTyping => throw UnimplementedError();
}
