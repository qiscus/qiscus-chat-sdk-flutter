import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/user.dart';
import 'package:qiscus_chat_sdk/src/features/user/repository.dart';

@immutable
class GetUserParams {
  final String query;
  final int page, limit;
  const GetUserParams({this.query, this.page, this.limit});
}

class GetUsers extends UseCase<UserRepository, List<User>, GetUserParams> {
  const GetUsers(UserRepository repository) : super(repository);

  @override
  Task<Either<Exception, List<User>>> call(GetUserParams p) {
    return repository.getUsers(
      query: p.query,
      page: p.page,
      limit: p.limit,
    );
  }
}
