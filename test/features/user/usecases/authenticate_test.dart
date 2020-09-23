import 'package:test/test.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';

class MockUserRepository extends Mock implements IUserRepository {}

void main() async {
  AuthenticateUserUseCase authenticate;
  IUserRepository userRepo;
  Storage storage;

  setUpAll(() {
    storage = Storage();
    userRepo = MockUserRepository();
    authenticate = AuthenticateUserUseCase(userRepo, storage);
  });

  test('successfully authenticate', () async {
    when(userRepo.authenticate(
      userId: anyNamed('userId'),
      userKey: anyNamed('userKey'),
    )).thenReturn(Task.delay(() => right(Tuple2(
        'some-token',
        Account(
          id: '123',
          name: some('name'),
        )))));

    var params = AuthenticateParams(
      userId: 'guest-1001',
      userKey: 'passkey',
    );
    var resp = await authenticate.call(params).run();
    expect(resp.isRight(), true);
    resp.fold<void>((err) {
      expect(err, null);
    }, (data) {
      expect(data.value1, 'some-token');
      expect(data.value2.id, '123');
      expect(data.value2.name, some('name'));
    });

    verify(userRepo.authenticate(
      userId: anyNamed('userId'),
      userKey: anyNamed('userKey'),
    )).called(1);
    expect(storage.userId, '123');
    expect(storage.token, 'some-token');
    verifyNoMoreInteractions(userRepo);
  });

  test('failure authenticate', () async {
    // region json response
    var json = <String, dynamic>{
      "error": {"code": 401306, "message": "wrong password"},
      "status": 401
    };
    // endregion

    when(userRepo.authenticate(
      userId: anyNamed('userId'),
      userKey: anyNamed('userKey'),
    )).thenReturn(
        Task.delay(() => left(QError(json['error']['message'] as String))));

    var params = AuthenticateParams(userId: 'guest-1001', userKey: 'wrong');
    var resp = await authenticate.call(params).run();
    expect(resp.isLeft(), true);
    resp.fold<void>((QError err) {
      expect(err.toString(), 'QError: wrong password');
    }, (data) {
      expect(data, null);
    });

    verify(userRepo.authenticate(
      userId: anyNamed('userId'),
      userKey: anyNamed('userKey'),
    )).called(1);
    verifyNoMoreInteractions(userRepo);
  });
}
