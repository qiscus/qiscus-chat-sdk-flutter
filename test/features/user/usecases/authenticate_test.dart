import 'package:qiscus_chat_sdk/src/type-utils.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/user/user.dart';

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
    )).thenAnswer((_) => Future.value(
      Tuple2(
        'some-token',
        Account(
          id: '123',
          name: Option.some('name'),
        ),
      ),
    ));

    var params = AuthenticateParams(
      userId: 'guest-1001',
      userKey: 'passkey',
    );
    var data = await authenticate.call(params);

    expect(data.first, 'some-token');
    expect(data.second.id, '123');
    expect(data.second.name, Option.some('name'));

    verify(userRepo.authenticate(
      userId: anyNamed('userId'),
      userKey: anyNamed('userKey'),
    )).called(1);
    expect(storage.userId, '123');
    expect(storage.token, 'some-token');
    verifyNoMoreInteractions(userRepo);
  });

  test('failure authenticate', () async {
    var json = <String, dynamic>{
      'error': {'code': 401306, 'message': 'wrong password'},
      'status': 401
    };

    when(userRepo.authenticate(
      userId: anyNamed('userId'),
      userKey: anyNamed('userKey'),
    )).thenAnswer((_) => Future.error(
          QError(json['error']['message'] as String),
        ));

    var params = AuthenticateParams(userId: 'guest-1001', userKey: 'wrong');
    try {
      await authenticate.call(params);
    } catch (err) {
      expect(err.toString(), 'QError(wrong password)');
    }

    // verify(userRepo.authenticate(
    //   userId: anyNamed('userId'),
    //   userKey: anyNamed('userKey'),
    // )).called(1);
    // verifyNoMoreInteractions(userRepo);
  });
}
