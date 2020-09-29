import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';
import 'package:test/test.dart';
import 'package:qiscus_chat_sdk/src/core.dart';

class MockUserRepo extends Mock implements IUserRepository {}

void main() {
  IUserRepository userRepo;
  GetUsersUseCase useCase;

  setUp(() {
    userRepo = MockUserRepo();
    useCase = GetUsersUseCase(userRepo);
  });

  test('get users success', () async {
    var users = [
      User(id: '1'.toOption()),
      User(id: '2'.toOption()),
    ];
    when(userRepo.getUsers(
      query: anyNamed('query'),
      limit: anyNamed('limit'),
      page: anyNamed('page'),
    )).thenReturn(Task(() async {
      return right(users);
    }));

    var resp = await useCase.call(GetUserParams()).run();

    resp.fold((error) {
      fail(error.toString());
    }, (data) {
      expect(data, users);
    });
  });
}
