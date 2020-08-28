part of qiscus_chat_sdk.usecase.user;

@immutable
class AuthenticateUserWithTokenUseCase
    extends UseCase<IUserRepository, Account, AuthenticateWithTokenParams> {
  final Storage _s;
  const AuthenticateUserWithTokenUseCase(IUserRepository repository, this._s)
      : super(repository);

  @override
  Task<Either<QError, Account>> call(AuthenticateWithTokenParams p) {
    return repository
        .authenticateWithToken(identityToken: p.identityToken)
        .tap((res) => _s.currentUser = res.value2)
        .tap((res) => _s.token = res.value1)
        .tap((res) => res.value2.lastEventId.do_((id) => _s.lastEventId = id))
        .tap((res) => res.value2.lastMessageId.do_(
              (id) => _s.lastMessageId = id,
            ))
        .rightMap((res) => res.value2);
  }
}

@immutable
class AuthenticateWithTokenParams {
  final String identityToken;
  const AuthenticateWithTokenParams(this.identityToken);
}
