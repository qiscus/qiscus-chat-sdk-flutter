import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/features/core/repository.dart';

import '../entity.dart';

class AppConfigUseCase extends UseCase<CoreRepository, AppConfig, NoParams> {
  AppConfigUseCase(CoreRepository repository, this._storage)
      : super(repository);
  final Storage _storage;

  @override
  Task<Either<Exception, AppConfig>> call(_) {
    return repository.getConfig().tap((c) => c.hydrateStorage(_storage));
  }
}
