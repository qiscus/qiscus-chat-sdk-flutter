part of qiscus_chat_sdk.usecase.app_config;

class AppConfigUseCase
    extends UseCase<AppConfigRepository, AppConfig, NoParams> {
  AppConfigUseCase(AppConfigRepository repository, this._storage)
      : super(repository);
  final Storage _storage;

  @override
  Future<AppConfig> call(_) async {
    try {
      var config = await repository.getConfig();
      config.hydrateStorage(_storage);
      return config;
    } catch (_) {
      return _storage.appConfig;
    }
  }
}
