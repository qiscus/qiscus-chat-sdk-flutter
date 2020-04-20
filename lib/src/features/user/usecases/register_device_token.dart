import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/user/repository.dart';

@immutable
class DeviceTokenParams {
  final String token;
  final bool isDevelopment;
  const DeviceTokenParams(this.token, [this.isDevelopment = false]);
}

class RegisterDeviceTokenUseCase
    extends UseCase<UserRepository, bool, DeviceTokenParams> {
  RegisterDeviceTokenUseCase(UserRepository repository) : super(repository);

  @override
  Task<Either<Exception, bool>> call(DeviceTokenParams p) {
    return repository.registerDeviceToken(
      token: p.token,
      isDevelopment: p.isDevelopment,
    );
  }
}

class UnregisterDeviceTokenUseCase
    extends UseCase<UserRepository, bool, DeviceTokenParams> {
  UnregisterDeviceTokenUseCase(UserRepository repository) : super(repository);

  @override
  Task<Either<Exception, bool>> call(DeviceTokenParams p) {
    return repository.unregisterDeviceToken(
      token: p.token,
      isDevelopment: p.isDevelopment,
    );
  }
}
