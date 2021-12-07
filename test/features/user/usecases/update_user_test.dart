import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/user/user.dart';
import 'package:qiscus_chat_sdk/src/type-utils.dart';
import 'package:test/test.dart';

class MockUserRepo extends Mock implements IUserRepository {}

void main() {
  IUserRepository repo;
  Storage storage;

  UpdateUserUseCase useCase;

  setUp(() {
    repo = MockUserRepo();
    storage = Storage();
    useCase = UpdateUserUseCase(repo, storage);
  });

  test('update user successfully', () async {
    var account = Account(
      id: '123456',
      name: Option.some('name'),
    );
    when(repo.updateUser(
      name: anyNamed('name'),
      avatarUrl: anyNamed('avatarUrl'),
      extras: anyNamed('extras'),
    )).thenAnswer((_) => Future.value(account));

    var r = await useCase.call(UpdateUserParams(name: 'name'));

    expect(r.name, account.name);

    verify(repo.updateUser(
      name: 'name',
    )).called(1);
    verifyNoMoreInteractions(repo);
  });
}
