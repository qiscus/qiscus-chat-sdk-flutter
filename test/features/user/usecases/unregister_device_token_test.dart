import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';
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
    )).thenAnswer((_) => Task.delay(
          () => right(true),
        ));

    var aa = useCase.call(DeviceTokenParams('some-token'));
    var resp = await aa.run();

    resp.fold((error) {
      fail(error.toString());
    }, (data) {
      expect(data, true);
    });
  });
}
