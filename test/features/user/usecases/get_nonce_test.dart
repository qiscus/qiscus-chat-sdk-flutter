import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/user/user.dart';
import 'package:test/test.dart';

class UserRepoMock extends Mock implements IUserRepository {}

void main() {
  IUserRepository userRepo;
  GetNonceUseCase useCase;

  setUpAll(() {
    userRepo = UserRepoMock();
    useCase = GetNonceUseCase(userRepo);
  });

  test('get nonce success', () async {
    when(userRepo.getNonce()).thenAnswer((_) => Future.value('ini nonce'));

    var data = await useCase.call(noParams);
    expect(data, 'ini nonce');
  });
}
