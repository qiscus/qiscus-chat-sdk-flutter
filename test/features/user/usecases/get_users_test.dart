import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/user/user.dart';
import 'package:qiscus_chat_sdk/src/type-utils.dart';
import 'package:test/test.dart';

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
      User(id: Option.some('1')),
      User(id: Option.some('2')),
    ];
    when(userRepo.getUsers(
      query: anyNamed('query'),
      limit: anyNamed('limit'),
      page: anyNamed('page'),
    )).thenAnswer((_) => Future.value(users));

    var data = await useCase.call(GetUserParams());

    expect(data, users);
  });
}
