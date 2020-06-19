import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/user.dart';
import 'package:qiscus_chat_sdk/src/features/user/repository.dart';

@immutable
class GetBlockedUserParams {
  final int page, limit;
  const GetBlockedUserParams({this.page, this.limit});
}

class GetBlockedUserUseCase
    extends UseCase<IUserRepository, List<User>, GetBlockedUserParams> {
  const GetBlockedUserUseCase(IUserRepository repository) : super(repository);

  @override
  Task<Either<QError, List<User>>> call(GetBlockedUserParams params) {
    return repository.getBlockedUser(
      page: params.page,
      limit: params.limit,
    );
  }
}
