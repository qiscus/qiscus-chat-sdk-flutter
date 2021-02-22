part of qiscus_chat_sdk.usecase.user;

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
  Future<Either<QError, bool>> call(DeviceTokenParams p) {
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
  Future<Either<QError, bool>> call(DeviceTokenParams p) {
    return repository.unregisterDeviceToken(
      token: p.token,
      isDevelopment: p.isDevelopment,
    );
  }
}
