import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/features/user/repository.dart';
import 'package:qiscus_chat_sdk/src/features/user/usecases/unblock_user.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';
import 'package:test/test.dart';

class MockUserRepo extends Mock implements IUserRepository {}

void main() {
  IUserRepository repo;
  UnblockUserUseCase useCase;

  setUpAll(() {
    repo = MockUserRepo();
    useCase = UnblockUserUseCase(repo);
  });

  test('unblock user successfully', () async {
    var user = User(id: 'id', name: some('name'));
    when(repo.unblockUser(
      userId: anyNamed('userId'),
    )).thenReturn(Task(() async {
      return right(user);
    }));

    var res = await useCase.call(UnblockUserParams('id')).run();
    res.fold(
        (l) => fail(l.message),
        (r) => expect(
              r.id,
              user.id,
            ));

    verify(repo.unblockUser(userId: user.id)).called(1);
    verifyNoMoreInteractions(repo);
  });
}
