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
  Task<Either<QError, User>> call(BlockUserParams params) {
    return repository.blockUser(userId: params.userId);
  }
}
