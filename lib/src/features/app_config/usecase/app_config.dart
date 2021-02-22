part of qiscus_chat_sdk.usecase.app_config;

class AppConfigUseCase
    extends UseCase<AppConfigRepository, AppConfig, NoParams> {
  AppConfigUseCase(AppConfigRepository repository, this._storage)
      : super(repository);
  final Storage _storage;

  @override
  Future<Either<QError, AppConfig>> call(_) async {
    return repository.getConfig().then((it) {
      it.hydrateStorage(_storage);
      return Either.right(it);
    }, onError: (Object error) {
      return Either.left(QError(error.toString()));
    });
  }
}
