import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/features/user/repository.dart';
import 'package:qiscus_chat_sdk/src/features/user/usecases/get_nonce.dart';
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
    when(userRepo.getNonce()).thenReturn(Task(() async {
      return right("ini nonce");
    }));

    var resp = await useCase.call(noParams).run();
    resp.fold((QError err) {
      fail(err.message);
    }, (data) {
      expect(data, 'ini nonce');
    });
  });
}
