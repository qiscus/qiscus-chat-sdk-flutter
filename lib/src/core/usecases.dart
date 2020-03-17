import 'package:dartz/dartz.dart';

class NoParams implements Eq {
  @override
  bool eq(a1, a2) => true;

  @override
  bool neq(a1, a2) => false;
}

abstract class UseCase<Repository, ReturnType, Params> {
  final Repository _repository;
  const UseCase(this._repository);
  Repository get repository => _repository;

  Task<Either<Exception, ReturnType>> call(Params params);
}

abstract class SubscriptionUseCase<Repository, ReturnType, Params> {
  final Repository _repository;
  const SubscriptionUseCase(this._repository);

  Repository get repository => _repository;

  Stream<ReturnType> subscribe(Params params);
}
