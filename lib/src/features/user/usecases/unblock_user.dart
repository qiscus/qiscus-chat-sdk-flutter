part of qiscus_chat_sdk.usecase.user;

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
  Future<Either<Error, User>> call(UnblockUserParams params) {
    return repository.unblockUser(userId: params.userId);
  }
}
