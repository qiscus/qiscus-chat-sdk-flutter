import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';
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
    )).thenReturn(Task.delay(
      () => right(
        Tuple2(
          'some-token',
          Account(
            id: '123',
            name: some('name'),
            lastEventId: some(123),
            lastMessageId: some(1111),
          ),
        ),
      ),
    ));

    var rr = await useCase(params).run();
    expect(rr.isRight(), true);
    rr.fold<void>((err) {
      expect(err, null);
    }, (data) {
      expect(data.id, '123');
    });

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
