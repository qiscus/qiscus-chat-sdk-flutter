import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/user/user.dart';
import 'package:test/test.dart';

class MockUserRepo extends Mock implements IUserRepository {}

void main() {
  IUserRepository userRepo;
  RegisterDeviceTokenUseCase useCase;

  setUpAll(() {
    userRepo = MockUserRepo();
    useCase = RegisterDeviceTokenUseCase(userRepo);
  });

  test('register device token success', () async {
    when(userRepo.registerDeviceToken(
      token: anyNamed('token'),
      isDevelopment: anyNamed('isDevelopment'),
    )).thenAnswer((_) => Future.value(true));

    var data = await useCase.call(DeviceTokenParams('some-token'));

    expect(data, true);
  });
}
