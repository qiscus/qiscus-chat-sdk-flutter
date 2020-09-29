part of qiscus_chat_sdk.usecase.app_config;

class AppConfigUseCase
    extends UseCase<AppConfigRepository, AppConfig, NoParams> {
  AppConfigUseCase(AppConfigRepository repository, this._storage)
      : super(repository);
  final Storage _storage;

  @override
  Task<Either<QError, AppConfig>> call(_) {
    return repository.getConfig().tap((c) => c.hydrateStorage(_storage));
  }
}
