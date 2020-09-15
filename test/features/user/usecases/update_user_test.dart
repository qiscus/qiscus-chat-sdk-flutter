import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';
import 'package:test/test.dart';

class MockUserRepo extends Mock implements IUserRepository {}

void main() {
  IUserRepository repo;
  Storage storage;

  UpdateUserUseCase useCase;

  setUpAll(() {
    repo = MockUserRepo();
    storage = Storage();
    useCase = UpdateUserUseCase(repo, storage);
  });

  test('update user successfully', () async {
    var account = Account(
      id: '123456',
      name: some('name'),
    );
    when(repo.updateUser(
      name: anyNamed('name'),
      avatarUrl: anyNamed('avatarUrl'),
      extras: anyNamed('extras'),
    )).thenReturn(Task(() async {
      return right(account);
    }));

    var resp = await useCase.call(UpdateUserParams(name: 'name')).run();

    resp.fold(
      (l) => fail(l.message),
      (r) => expect(r.name, account.name),
    );

    verify(repo.updateUser(
      name: 'name',
    )).called(1);
    verifyNoMoreInteractions(repo);
  });
}
