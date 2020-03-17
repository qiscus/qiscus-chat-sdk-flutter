import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/account.dart';
import 'package:qiscus_chat_sdk/src/features/user/repository.dart';

class GetUserData extends UseCase<UserRepository, Account, NoParams> {
  const GetUserData(UserRepository repository) : super(repository);

  @override
  Task<Either<Exception, Account>> call(_) {
    return repository.getUserData();
  }
}
