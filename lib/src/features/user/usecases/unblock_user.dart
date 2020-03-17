import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/user.dart';
import 'package:qiscus_chat_sdk/src/features/user/repository.dart';

@immutable
class UnblockUserParams {
  final String userId;
  const UnblockUserParams(this.userId);
}

@immutable
class UnblockUser extends UseCase<UserRepository, User, UnblockUserParams> {
  const UnblockUser(UserRepository repository) : super(repository);

  @override
  Task<Either<Exception, User>> call(UnblockUserParams params) {
    return repository.unblockUser(userId: params.userId);
  }
}
