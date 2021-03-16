import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/user/user.dart';
import 'package:qiscus_chat_sdk/src/type_utils.dart';
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
        name: Option.some('name'),
      );

      when(repo.getUserData()).thenAnswer((_) => Future.value(account));

      var r = await useCase.call(noParams);

      expect(r.id, account.id);
      expect(r.name, account.name);

      verify(repo.getUserData()).called(1);
      verifyNoMoreInteractions(repo);
    });
  });
}
