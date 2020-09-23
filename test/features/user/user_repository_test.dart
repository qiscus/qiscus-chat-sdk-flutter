import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';
import 'package:test/test.dart';

import '../../utils.dart';
import 'backend_response.dart';

void main() {
  group('UserRepository', () {
    IUserRepository repo;
    Dio dio;

    setUpAll(() {
      dio = MockDio();
      repo = UserRepositoryImpl(dio);
    });

    test('authenticate', () async {
      var response = loginOrRegisterResponse;
      var user = response['results']['user'] as Map<String, dynamic>;
      var account = Account(
        id: user['email'] as String,
        name: some(user['username'] as String),
      );

      makeTest(dio, loginOrRegisterResponse);

      var resp = await repo
          .authenticate(
            userId: 'user-id',
            userKey: 'passkey',
          )
          .run();
      resp.fold((l) => fail(l.message), (r) {
        expect(r.value1, user['token']);
        expect(r.value2.id, account.id);

        expect(r.value1, user['token']);
        expect(r.value2.id, account.id);
        expect(r.value2.name, account.name);
      });
    });

    test('authenticate with token', () async {
      var response = authenticateWithTokenResponse;
      var user = response['results']['user'] as Map<String, dynamic>;
      final account = Account(
        id: user['email'] as String,
        name: some(user['username'] as String),
      );

      makeTest(dio, response);

      var resp = await repo
          .authenticateWithToken(identityToken: 'identity-token')
          .run();

      resp.fold((l) => fail(l.message), (r) {
        expect(r.value1, user['token']);
        expect(r.value2.id, account.id);
        expect(r.value2.name, account.name);
      });
    });

    test('blockUser', () async {
      var response = blockUserResponse;
      var user = response['results']['user'] as Map<String, dynamic>;

      makeTest(dio, response);

      var resp = await repo.blockUser(userId: 'id').run();
      resp.fold((l) => fail(l.message), (r) {
        expect(r.id, some(user['email'] as String));
        expect(r.name, some(user['username'] as String));
      });
    });

    test('unblockUser', () async {
      final response = unblockUserResponse;
      final user = response['results']['user'] as Map<String, dynamic>;

      makeTest(dio, response);

      var resp = await repo.unblockUser(userId: 'id').run();
      resp.fold((l) => fail(l.message), (r) {
        expect(r.id, some(user['email'] as String));
        expect(r.name, some(user['username'] as String));
      });
    });

    test('getBlockedUsers', () async {
      var response = getBlockedUsersResponse;
      var users = (response['results']['blocked_users'] as List)
          .cast<Map<String, dynamic>>();
      var user = users.first;

      makeTest(dio, response);

      var resp = await repo.getBlockedUser(page: 1, limit: 1).run();

      resp.fold((l) => fail(l.message), (r) {
        expect(r.first.id, some(user['email'] as String));
        expect(r.first.name, some(user['username'] as String));
      });
    });

    test('getNonce', () async {
      var response = getNonceResponse;
      var nonce = response['results']['nonce'] as String;

      makeTest(dio, response);

      var resp = await repo.getNonce().run();
      resp.fold((l) => fail(l.message), (r) {
        expect(r, nonce);
      });
    });

    test('getUserData', () async {
      var response = getUserDataResponse;
      var user = response['results']['user'] as Map<String, dynamic>;

      makeTest(dio, response);

      var resp = await repo.getUserData().run();
      resp.fold((l) => fail(l.message), (r) {
        expect(r.id, user['email']);
        expect(r.name, some(user['username'] as String));
      });
    });

    test('getUsers', () async {
      var response = getUsersResponse;
      var users =
          (response['results']['users'] as List).cast<Map<String, dynamic>>();
      var user = users.first;

      makeTest(dio, response);

      var resp = await repo.getUsers(query: '', page: 1, limit: 2).run();
      resp.fold((l) => fail(l.message), (r) {
        expect(r.length, 1);
        expect(r.first.id, some(user['email'] as String));
        expect(r.first.name, some(user['username'] as String));
      });
    });

    test('registerDeviceToken', () async {
      var response = setDeviceTokenResponse;
      makeTest(dio, response);

      var resp = await repo.registerDeviceToken(token: 'ini-token').run();
      resp.fold((l) => fail(l.message), (r) {
        expect(r, response['results']['changed']);
      });
    });

    test('unregisterDeviceToken', () async {
      var response = unsetDeviceTokenResponse;

      makeTest(dio, response);

      var resp = await repo.unregisterDeviceToken(token: 'ini-token').run();
      resp.fold((l) => fail(l.message), (r) {
        expect(r, response['results']['success']);
      });
    });

    test('updateUser', () async {
      var response = updateUserDataResponse;
      var user = response['results']['user'] as Map<String, dynamic>;
      makeTest(dio, response);

      var resp = await repo
          .updateUser(
            name: 'update name',
            avatarUrl: 'avatar-url',
          )
          .run();
      resp.fold((l) => fail(l.message), (r) {
        expect(r.id, user['email']);
        expect(r.name, some(user['username'] as String));
      });
    });
  });
}
