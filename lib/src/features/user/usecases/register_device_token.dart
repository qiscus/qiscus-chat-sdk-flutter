import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/user/repository.dart';

@immutable
class DeviceTokenParams {
  final String token;
  final bool isDevelopment;
  const DeviceTokenParams(this.token, [this.isDevelopment = false]);
}

class RegisterDeviceTokenUseCase
    extends UseCase<IUserRepository, bool, DeviceTokenParams> {
  RegisterDeviceTokenUseCase(IUserRepository repository) : super(repository);

  @override
  Task<Either<QError, bool>> call(DeviceTokenParams p) {
    return repository.registerDeviceToken(
      token: p.token,
      isDevelopment: p.isDevelopment,
    );
  }
}

class UnregisterDeviceTokenUseCase
    extends UseCase<IUserRepository, bool, DeviceTokenParams> {
  UnregisterDeviceTokenUseCase(IUserRepository repository) : super(repository);

  @override
  Task<Either<QError, bool>> call(DeviceTokenParams p) {
    return repository.unregisterDeviceToken(
      token: p.token,
      isDevelopment: p.isDevelopment,
    );
  }
}
