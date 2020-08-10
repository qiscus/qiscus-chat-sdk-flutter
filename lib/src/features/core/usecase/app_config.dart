import 'package:dartz/dartz.dart';

import '../../../core/core.dart';
import '../entity.dart';
import '../repository.dart';

class AppConfigUseCase extends UseCase<CoreRepository, AppConfig, NoParams> {
  AppConfigUseCase(CoreRepository repository, this._storage)
      : super(repository);
  final Storage _storage;

  @override
  Task<Either<QError, AppConfig>> call(_) {
    return repository.getConfig().tap((c) => c.hydrateStorage(_storage));
  }
}
