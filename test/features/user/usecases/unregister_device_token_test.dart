import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/user/user.dart';
import 'package:test/test.dart';

class MockUserRepo extends Mock implements IUserRepository {}

void main() {
  IUserRepository userRepo;
  UnregisterDeviceTokenUseCase useCase;

  setUpAll(() {
    userRepo = MockUserRepo();
    useCase = UnregisterDeviceTokenUseCase(userRepo);
  });

  test('unregister device token success', () async {
    when(userRepo.unregisterDeviceToken(
      token: anyNamed('token'),
      isDevelopment: anyNamed('isDevelopment'),
    )).thenAnswer((_) => Future.value(true));

    var data = await useCase.call(DeviceTokenParams('some-token'));

    expect(data, true);
  });
}
