import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/user/repository.dart';

class GetNonce extends UseCase<UserRepository, String, NoParams> {
  GetNonce(UserRepository repository) : super(repository);

  @override
  Task<Either<Exception, String>> call(NoParams params) {
    return repository.getNonce();
  }
}
