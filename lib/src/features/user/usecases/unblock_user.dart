import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/user.dart';
import 'package:qiscus_chat_sdk/src/features/user/repository.dart';

@immutable
class UnblockUserParams {
  final String userId;
  const UnblockUserParams(this.userId);
}

@immutable
class UnblockUserUseCase
    extends UseCase<IUserRepository, User, UnblockUserParams> {
  const UnblockUserUseCase(IUserRepository repository) : super(repository);

  @override
  Task<Either<QError, User>> call(UnblockUserParams params) {
    return repository.unblockUser(userId: params.userId);
  }
}
