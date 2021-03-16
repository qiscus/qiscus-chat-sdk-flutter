part of qiscus_chat_sdk.usecase.user;

class GetNonceUseCase extends UseCase<IUserRepository, String, NoParams> {
  GetNonceUseCase(IUserRepository repository) : super(repository);

  @override
  Future<String> call(NoParams params) {
    return repository.getNonce();
  }
}
