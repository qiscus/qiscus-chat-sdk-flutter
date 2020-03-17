import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';
import 'package:qiscus_chat_sdk/src/core/storage.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/account.dart';
import 'package:qiscus_chat_sdk/src/features/user/repository.dart';

@immutable
class AuthenticateWithToken
    extends UseCase<UserRepository, Account, AuthenticateWithTokenParams> {
  final Storage _s;
  const AuthenticateWithToken(UserRepository repository, this._s)
      : super(repository);

  @override
  Task<Either<Exception, Account>> call(AuthenticateWithTokenParams p) {
    return repository
        .authenticateWithToken(identityToken: p.identityToken)
        .tap((res) => _s.currentUser = res.user)
        .tap((res) => _s.token = res.token)
        .rightMap((res) => res.user);
  }
}

@immutable
class AuthenticateWithTokenParams {
  final String identityToken;
  const AuthenticateWithTokenParams(this.identityToken);
}
