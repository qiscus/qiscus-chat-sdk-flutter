import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/user.dart';
import 'package:qiscus_chat_sdk/src/features/user/repository.dart';

@immutable
class BlockUserParams {
  final String userId;
  const BlockUserParams(this.userId);
}

@immutable
class BlockUserUseCase extends UseCase<IUserRepository, User, BlockUserParams> {
  const BlockUserUseCase(IUserRepository repository) : super(repository);

  @override
  Task<Either<Exception, User>> call(BlockUserParams params) {
    return repository.blockUser(userId: params.userId);
  }
}
