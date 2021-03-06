part of qiscus_chat_sdk.usecase.user;

class GetUserDataUseCase extends UseCase<IUserRepository, Account, NoParams> {
  const GetUserDataUseCase(IUserRepository repository) : super(repository);

  @override
  Future<Account> call(_) {
    return repository.getUserData();
  }
}
