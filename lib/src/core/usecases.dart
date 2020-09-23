part of qiscus_chat_sdk.core;

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object> get props => [];
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

  Task<Either<QError, ReturnType>> call(Params params);
}
