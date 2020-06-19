import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/account.dart';
import 'package:qiscus_chat_sdk/src/features/user/repository.dart';

class GetUserDataUseCase extends UseCase<IUserRepository, Account, NoParams> {
  const GetUserDataUseCase(IUserRepository repository) : super(repository);

  @override
  Task<Either<QError, Account>> call(_) {
    return repository.getUserData();
  }
}
