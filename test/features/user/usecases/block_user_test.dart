import 'package:dartz/dartz.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/user.dart';
import 'package:qiscus_chat_sdk/src/features/user/repository.dart';
import 'package:qiscus_chat_sdk/src/features/user/usecases/block_user.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';

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
      id: 'user-id'.toOption(),
      name: some('user'),
    );
    when(repo.blockUser(userId: anyNamed('userId')))
        .thenReturn(Task.delay(() => right(user)));

    var params = BlockUserParams('user-id');
    var resp = await blockUser(params).run();

    expect(resp.isRight(), true);
    resp.fold((_) {
      fail('Not blocking user successfully');
    }, (u) {
      expect(u.id, user.id);
      expect(u.name, user.name);
    });

    verify(repo.blockUser(userId: anyNamed('userId'))).called(1);
    verifyNoMoreInteractions(repo);
  });
}
