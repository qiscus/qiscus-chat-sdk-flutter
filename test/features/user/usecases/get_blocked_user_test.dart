import 'package:dartz/dartz.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/features/user/repository.dart';
import 'package:qiscus_chat_sdk/src/features/user/usecases/get_blocked_user.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';

class MockUserRepository extends Mock implements IUserRepository {}

void main() async {
  GetBlockedUserUseCase getBlockedUser;
  IUserRepository repo;

  setUpAll(() async {
    repo = MockUserRepository();
    getBlockedUser = GetBlockedUserUseCase(repo);
  });

  test('successfully get blocked user', () async {
    var params = GetBlockedUserParams();

    when(repo.getBlockedUser(page: anyNamed('page'), limit: anyNamed('limit')))
        .thenReturn(Task.delay(() {
      var users = <User>[];
      return right(users);
    }));

    var resp = await getBlockedUser(params).run();

    resp.fold((err) {
      fail('must not be failure');
    }, (users) {
      if (users == null) fail('users should not null');
      expect(users.length, 0);
    });

    verify(repo.getBlockedUser(
      page: anyNamed('page'),
      limit: anyNamed('limit'),
    )).called(1);
    verifyNoMoreInteractions(repo);
  });
}
