import 'package:qiscus_chat_sdk/src/features/user/repository.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

class MockUserAPI extends Mock implements UserApi {}

void main() {
  group('UserRepository', () {
    IUserRepository repo;
    UserApi api;

    setUpAll(() {
      api = MockUserAPI();
      repo = UserRepositoryImpl(api);
    });

    test('authenticate', () async {
      var account = Account(
        id: 'id',
        name: some('name'),
      );
      var token = 'ini-token';
      when(api.authenticate(any)).thenAnswer((_) {
        return Future.value(AuthenticateResponse(token, account));
      });

      var resp = await repo
          .authenticate(
            userId: 'user-id',
            userKey: 'passkey',
          )
          .run();
      resp.fold((l) => fail(l.message), (r) {
        expect(r.token, token);
        expect(r.user.id, account.id);
        expect(r.user.name, account.name);
      });

      verify(api.authenticate(AuthenticateRequest(
        'user-id',
        'passkey',
      ))).called(1);
      verifyNoMoreInteractions(api);
    });

    test('authenticate with token', () async {
      final account = Account(
        id: 'id',
        name: some('name'),
      );
      when(api.authenticateWithToken(any)).thenAnswer((_) {
        return Future.value(AuthenticateResponse('ini-token', account));
      });

      var resp = await repo
          .authenticateWithToken(identityToken: 'identity-token')
          .run();

      resp.fold((l) => fail(l.message), (r) {
        expect(r.token, 'ini-token');
        expect(r.user.id, account.id);
        expect(r.user.name, account.name);
      });

      verify(api.authenticateWithToken(
              AuthenticateWithTokenRequest('identity-token')))
          .called(1);
      verifyNoMoreInteractions(api);
    });

    test('blockUser', () async {
      when(api.blockUser(any)).thenAnswer((_) {
        return Future.value(User(
          id: 'id',
          name: some('name'),
        ));
      });

      var resp = await repo.blockUser(userId: 'id').run();
      resp.fold((l) => fail(l.message), (r) {
        expect(r.id, 'id');
        expect(r.name, some('name'));
      });

      verify(api.blockUser(BlockUserRequest('id'))).called(1);
      verifyNoMoreInteractions(api);
    });

    test('unblockUser', () async {
      when(api.unblockUser(any)).thenAnswer((_) {
        return Future.value(User(
          id: 'id',
          name: some('name'),
        ));
      });

      var resp = await repo.unblockUser(userId: 'id').run();
      resp.fold((l) => fail(l.message), (r) {
        expect(r.id, 'id');
        expect(r.name, some('name'));
      });

      verify(api.unblockUser(BlockUserRequest('id'))).called(1);
      verifyNoMoreInteractions(api);
    });

    test('getBlockedUsers', () async {
      when(api.getBlockedUsers(
        page: anyNamed('page'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) {
        return Future.value(<User>[
          User(id: 'id-1', name: some('name-1')),
          User(id: 'id-2', name: some('name-2')),
        ]);
      });

      var resp = await repo.getBlockedUser(page: 1, limit: 2).run();
      resp.fold((l) => fail(l.message), (r) {
        expect(r.length, 2);
        for (var i = 0; i < 2; i++) {
          expect(r[i].id, 'id-${i + 1}');
          expect(r[i].name, some('name-${i + 1}'));
        }
      });

      verify(api.getBlockedUsers(page: 1, limit: 2)).called(1);
      verifyNoMoreInteractions(api);
    });

    test('getNonce', () async {
      when(api.getNonce()).thenAnswer((_) {
        return Future.value(GetNonceResponse('nonce'));
      });

      var resp = await repo.getNonce().run();
      resp.fold((l) => fail(l.message), (r) {
        expect(r, 'nonce');
      });

      verify(api.getNonce()).called(1);
      verifyNoMoreInteractions(api);
    });

    test('getUserData', () async {
      when(api.getUserData()).thenAnswer((_) {
        return Future.value(GetUserResponse(Account(id: 'id')));
      });

      var resp = await repo.getUserData().run();
      resp.fold((l) => fail(l.message), (r) {
        expect(r.id, 'id');
      });

      verify(api.getUserData()).called(1);
      verifyNoMoreInteractions(api);
    });

    test('getUsers', () async {
      when(api.getUsers(
        query: anyNamed('query'),
        limit: anyNamed('limit'),
        page: anyNamed('page'),
      )).thenAnswer((_) {
        return Future.value(UsersResponse(<User>[
          User(id: 'id-1', name: some('name-1')),
          User(id: 'id-2', name: some('name-2')),
        ]));
      });

      var resp = await repo.getUsers(query: '', page: 1, limit: 2).run();
      resp.fold((l) => fail(l.message), (r) {
        expect(r.length, 2);
        for (var i = 0; i < 2; i++) {
          expect(r[i].id, 'id-${i + 1}');
          expect(r[i].name, some('name-${i + 1}'));
        }
      });

      verify(api.getUsers(query: '', page: 1, limit: 2)).called(1);
      verifyNoMoreInteractions(api);
    });

    test('registerDeviceToken', () async {
      when(api.registerDeviceToken(any)).thenAnswer((_) {
        return Future.value(
          '{"results":{"changed":true,"pn_android_configured":true,"pn_ios_configured":false},"status":200}',
        );
      });

      var resp = await repo.registerDeviceToken(token: 'ini-token').run();
      resp.fold((l) => fail(l.message), (r) {
        expect(r, true);
      });

      verify(api.registerDeviceToken(DeviceTokenRequest(
        'ini-token',
      ))).called(1);
      verifyNoMoreInteractions(api);
    });

    test('unregisterDeviceToken', () async {
      when(api.unregisterDeviceToken(any)).thenAnswer((_) {
        return Future.value('{"results":{"success":true},"status":200}');
      });

      var resp = await repo.unregisterDeviceToken(token: 'ini-token').run();
      resp.fold((l) => fail(l.message), (r) {
        expect(r, true);
      });

      verify(api.unregisterDeviceToken(DeviceTokenRequest('ini-token')))
          .called(1);
      verifyNoMoreInteractions(api);
    });

    test('updateUser', () async {
      when(api.updateUser(any)).thenAnswer((_) {
        return Future.value(
          '{"results":{"user":{"active":true,"app":{"code":"sdksample","id":947,"id_str":"947","name":"sdksample"},"avatar":{"avatar":{"url":"https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/GoLdHEInn5/Screenshot+(11).png"}},"avatar_url":"https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/GoLdHEInn5/Screenshot+(11).png","email":"guest-1001","extras":{"extras":true},"id":44465689,"id_str":"44465689","last_comment_id":0,"last_comment_id_str":"0","last_sync_event_id":0,"pn_android_configured":true,"pn_ios_configured":false,"rtKey":"somestring","token":"DliiUcM3RdiRtlTyYpHK","username":"guest-1001 updated"}},"status":200}',
        );
      });

      var resp = await repo
          .updateUser(
            name: 'update name',
            avatarUrl: 'avatar-url',
          )
          .run();
      resp.fold((l) => fail(l.message), (r) {
        expect(r.name, some('guest-1001 updated'));
      });

      verify(api.updateUser(UpdateUserRequest(
        name: 'update name',
        avatarUrl: 'avatar-url',
      ))).called(1);
      verifyNoMoreInteractions(api);
    });
  });
}
