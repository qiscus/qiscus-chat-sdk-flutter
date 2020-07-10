import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/features/user/repository.dart';
import 'package:qiscus_chat_sdk/src/features/user/usecases/get_user_data.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

class MockUserRepo extends Mock implements IUserRepository {}

void main() {
  group('GetUserDataUseCase', () {
    IUserRepository repo;
    GetUserDataUseCase useCase;

    setUpAll(() {
      repo = MockUserRepo();
      useCase = GetUserDataUseCase(repo);
    });

    test('get profile successfully', () async {
      var account = Account(
        id: 'id',
        name: some('name'),
      );

      when(repo.getUserData()).thenReturn(Task(() async {
        return right(account);
      }));

      var resp = await useCase.call(noParams).run();

      resp.fold((l) => fail(l.message), (r) {
        expect(r.id, account.id);
        expect(r.name, account.name);
      });

      verify(repo.getUserData()).called(1);
      verifyNoMoreInteractions(repo);
    });
  });
}
