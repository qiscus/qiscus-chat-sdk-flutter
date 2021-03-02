import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
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
        .thenAnswer((_) => Future.value(<User>[]));

    var users = await getBlockedUser(params);

    if (users == null) fail('users should not null');
    expect(users.length, 0);

    verify(repo.getBlockedUser(
      page: anyNamed('page'),
      limit: anyNamed('limit'),
    )).called(1);
    verifyNoMoreInteractions(repo);
  });
}
