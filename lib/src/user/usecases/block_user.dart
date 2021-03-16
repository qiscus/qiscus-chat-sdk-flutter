part of qiscus_chat_sdk.usecase.user;

@immutable
class BlockUserParams {
  final String userId;
  const BlockUserParams(this.userId);
}

@immutable
class BlockUserUseCase extends UseCase<IUserRepository, User, BlockUserParams> {
  const BlockUserUseCase(IUserRepository repository) : super(repository);

  @override
  Future<User> call(BlockUserParams params) async {
    return repository.blockUser(userId: params.userId);
  }
}
