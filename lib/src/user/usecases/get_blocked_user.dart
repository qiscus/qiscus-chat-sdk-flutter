part of qiscus_chat_sdk.usecase.user;

@immutable
class GetBlockedUserParams {
  final int? page, limit;
  const GetBlockedUserParams({this.page, this.limit});
}

class GetBlockedUserUseCase
    extends UseCase<IUserRepository, List<User>, GetBlockedUserParams> {
  const GetBlockedUserUseCase(IUserRepository repository) : super(repository);

  @override
  Future<List<User>> call(GetBlockedUserParams params) {
    return repository.getBlockedUser(
      page: params.page,
      limit: params.limit,
    );
  }
}
