import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/features/user/repository.dart';
import 'package:qiscus_chat_sdk/src/features/user/usecases/get_user_data.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';
import 'package:test/test.dart';

class MockUserRepo extends Mock implements IUserRepository {}

void main() {
  IUserRepository userRepo;
  GetUserDataUseCase useCase;

  setUpAll(() {
    userRepo = MockUserRepo();
    useCase = GetUserDataUseCase(userRepo);
  });

  test('get profile successfully', () async {
    var account = Account(
      id: 'id',
      name: some('name'),
    );
    when(userRepo.getUserData()).thenReturn(Task(() async {
      return right(account);
    }));

    var resp = await useCase.call(noParams).run();
    resp.fold(
      (l) => fail(l.message),
      (r) => expect(r.name, account.name),
    );
  });
}
