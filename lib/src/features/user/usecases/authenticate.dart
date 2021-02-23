part of qiscus_chat_sdk.usecase.user;

@immutable
class AuthenticateUserUseCase extends UseCase<IUserRepository,
    Tuple2<String, Account>, AuthenticateParams> {
  final Storage _storage;

  const AuthenticateUserUseCase(IUserRepository repository, this._storage)
      : super(repository);

  @override
  Future<Either<Error, Tuple2<String, Account>>> call(
    AuthenticateParams p,
  ) async {
    var resp = await repository.authenticate(
      userId: p.userId,
      userKey: p.userKey,
      name: p.name,
      avatarUrl: p.avatarUrl,
      extras: p.extras,
    );
    resp.map((it) {
      var token = it.first;
      var user = it.second;
      _storage
        ..token = token
        ..currentUser = user
        ..lastMessageId =
            user.lastMessageId.getOrElse(() => _storage.lastMessageId)
        ..lastEventId = user.lastEventId.getOrElse(() => _storage.lastEventId);
    });

    return resp;
  }
}

@immutable
class AuthenticateParams {
  final String userId;
  final String userKey;
  final String name;
  final String avatarUrl;
  final Map<String, dynamic> extras;

  const AuthenticateParams({
    @required this.userId,
    @required this.userKey,
    this.name,
    this.avatarUrl,
    this.extras,
  });
}
