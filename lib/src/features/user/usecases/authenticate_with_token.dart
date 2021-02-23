part of qiscus_chat_sdk.usecase.user;

@immutable
class AuthenticateUserWithTokenUseCase
    extends UseCase<IUserRepository, Account, AuthenticateWithTokenParams> {
  final Storage _s;
  const AuthenticateUserWithTokenUseCase(IUserRepository repository, this._s)
      : super(repository);

  @override
  Future<Either<Error, Account>> call(AuthenticateWithTokenParams p) async {
    var it =
        await repository.authenticateWithToken(identityToken: p.identityToken);

    return it.map((it) {
      _s.currentUser = it.second;
      _s.token = it.first;
      _s.lastEventId = it.second.lastEventId.getOrElse(() => _s.lastEventId);
      _s.lastMessageId =
          it.second.lastMessageId.getOrElse(() => _s.lastMessageId);
      return it.second;
    });
  }
}

@immutable
class AuthenticateWithTokenParams {
  final String identityToken;
  const AuthenticateWithTokenParams(this.identityToken);
}
