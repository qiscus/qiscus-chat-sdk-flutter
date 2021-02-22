part of qiscus_chat_sdk.usecase.user;

class GetNonceUseCase extends UseCase<IUserRepository, String, NoParams> {
  GetNonceUseCase(IUserRepository repository) : super(repository);

  @override
  Future<Either<QError, String>> call(NoParams params) {
    return repository.getNonce();
  }
}
