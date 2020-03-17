import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/user.dart';
import 'package:qiscus_chat_sdk/src/features/user/repository.dart';

@immutable
class GetBlockedUserParams {
  final int page, limit;
  const GetBlockedUserParams({this.page, this.limit});
}

class GetBlockedUser
    extends UseCase<UserRepository, List<User>, GetBlockedUserParams> {
  const GetBlockedUser(UserRepository repository) : super(repository);

  @override
  Task<Either<Exception, List<User>>> call(GetBlockedUserParams params) {
    return repository.getBlockedUser(
      page: params.page,
      limit: params.limit,
    );
  }
}
