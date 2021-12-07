import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/user/user.dart';
import 'package:qiscus_chat_sdk/src/type-utils.dart';
import 'package:test/test.dart';

class MockUserRepository extends Mock implements IUserRepository {}

void main() {
  AuthenticateUserWithTokenUseCase useCase;
  IUserRepository userRepo;
  Storage storage;

  setUpAll(() async {
    storage = Storage();
    userRepo = MockUserRepository();
    useCase = AuthenticateUserWithTokenUseCase(userRepo, storage);
  });

  test('authenticate with token successfully', () async {
    var token = 'qwe12345';
    var params = AuthenticateWithTokenParams(token);

    when(userRepo.authenticateWithToken(
      identityToken: anyNamed('identityToken'),
    )).thenAnswer((_) => Future.value(
      Tuple2(
        'some-token',
        Account(
          id: '123',
          name: Option.some('name'),
          lastEventId: Option.some(123),
          lastMessageId: Option.some(1111),
        ),
      ),
    ));

    var data = await useCase(params);
    expect(data.id, '123');

    expect(storage.userId, '123');
    expect(storage.token, 'some-token');
    expect(storage.lastEventId, 123);
    expect(storage.lastMessageId, 1111);

    verify(userRepo.authenticateWithToken(
            identityToken: anyNamed('identityToken')))
        .called(1);
    verifyNoMoreInteractions(userRepo);
  });
}
