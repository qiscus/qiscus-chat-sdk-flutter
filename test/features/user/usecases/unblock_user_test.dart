import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/core.dart';

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
        id: 'id'.toOption(),
        name: some('name'),
      );
      when(repo.unblockUser(
        userId: anyNamed('userId'),
      )).thenReturn(Task(() async {
        return right(user);
      }));

      var params = UnblockUserParams(user.id.toNullable());
      var resp = await useCase.call(params).run();

      resp.fold((l) => fail(l.message), (r) {
        expect(r.id, user.id);
        expect(r.name, user.name);
      });

      verify(repo.unblockUser(userId: user.id.toNullable())).called(1);
      verifyNoMoreInteractions(repo);
    });
  });
}
