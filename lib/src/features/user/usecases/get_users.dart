part of qiscus_chat_sdk.usecase.user;

@immutable
class GetUserParams {
  final String query;
  final int page, limit;
  const GetUserParams({this.query, this.page, this.limit});
}

class GetUsersUseCase
    extends UseCase<IUserRepository, List<User>, GetUserParams> {
  const GetUsersUseCase(IUserRepository repository) : super(repository);

  @override
  Task<Either<QError, List<User>>> call(GetUserParams p) {
    return repository.getUsers(
      query: p.query,
      page: p.page,
      limit: p.limit,
    );
  }
}
