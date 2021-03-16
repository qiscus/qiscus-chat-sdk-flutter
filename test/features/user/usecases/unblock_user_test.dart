import 'package:qiscus_chat_sdk/src/user/user.dart';
import 'package:qiscus_chat_sdk/src/type_utils.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

class MockUserRepo extends Mock implements IUserRepository {}

void main() {
  group('UnblockUserUseCase', () {
    IUserRepository repo;
    UnblockUserUseCase useCase;

    setUpAll(() {
      repo = MockUserRepo();
      useCase = UnblockUserUseCase(repo);
    });

    test('unblock user successfully', () async {
      var user = User(
        id: Option.some('id'),
        name: Option.some('name'),
      );
      when(repo.unblockUser(
        userId: anyNamed('userId'),
      )).thenAnswer((_) => Future.value(user));

      var params = UnblockUserParams(user.id.toNullable());
      var r = await useCase.call(params);

      expect(r.id, user.id);
      expect(r.name, user.name);

      verify(repo.unblockUser(userId: user.id.toNullable())).called(1);
      verifyNoMoreInteractions(repo);
    });
  });
}
