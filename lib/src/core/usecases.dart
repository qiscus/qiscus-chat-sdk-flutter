part of qiscus_chat_sdk.core;

class NoParams with EquatableMixin {
  const NoParams();

  @override
  List<Object> get props => [];
  @override
  bool get stringify => true;
}

const noParams = NoParams();

class NoRepository extends Equatable {
  const NoRepository();

  @override
  List<Object> get props => [];
}

final noRepository = const NoRepository();

abstract class UseCase<Repository, ReturnType, Params> {
  final Repository _repository;

  const UseCase(this._repository);

  Repository get repository => _repository;

  Future<Either<QError, ReturnType>> call(Params params);
}

abstract class $$UseCase<Dependency, ReturnType, Params> {
  final Dependency deps;
  const $$UseCase(this.deps);

  FutureOr<ReturnType> call(Params params);
}
