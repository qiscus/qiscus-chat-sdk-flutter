import 'package:qiscus_chat_sdk/src/type-utils.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/user/user.dart';

class MockUserRepository extends Mock implements IUserRepository {}

void main() {
  IUserRepository repo;
  BlockUserUseCase blockUser;

  setUpAll(() {
    repo = MockUserRepository();
    blockUser = BlockUserUseCase(repo);
  });

  test('block user successfully', () async {
    var user = User(
      id: Option.some('user-id'),
      name: Option.some('user'),
    );
    when(repo.blockUser(userId: anyNamed('userId')))
        .thenAnswer((_) => Future.value(user));

    var params = BlockUserParams('user-id');
    var u = await blockUser(params);

    expect(u.id, user.id);
    expect(u.name, user.name);

    verify(repo.blockUser(userId: anyNamed('userId'))).called(1);
    verifyNoMoreInteractions(repo);
  });
}
