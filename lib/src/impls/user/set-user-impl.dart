import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/user/user-model.dart';

import 'account-from-json.dart';

RTE<State<Storage, QAccount>> setUserImpl({
  required String userId,
  required String userKey,
  String? displayName,
  String? avatarUrl,
  Json? extras,
}) {
  return tryCR((dio) async {
    var req = AuthenticateRequest(
      userId: userId,
      userKey: userKey,
    );
    var data = await req(dio);
    return State((Storage s) {
      s.token = data.first;
      s.currentUser = data.second;
      return Tuple2(data.second, s);
    });
  });
}

RTE<State<Storage, QAccount>> setUserWithIdentityTokenImpl(String token) {
  return tryCR((dio) async {
    var req = AuthenticateWithTokenRequest(identityToken: token);
    var data = await req(dio);

    return State((s) {
      s.token = data.first;
      s.currentUser = data.second;

      return Tuple2(data.second, s);
    });
  });
}

class AuthenticateRequest extends IApiRequest<Tuple2<String, QAccount>> {
  AuthenticateRequest({
    required this.userId,
    required this.userKey,
    this.name,
    this.avatarUrl,
    this.extras,
  });

  final String userId;
  final String userKey;
  final String? name;
  final String? avatarUrl;
  final Json? extras;

  @override
  String get url => 'login_or_register';

  @override
  IRequestMethod get method => IRequestMethod.post;

  @override
  Json get body => <String, dynamic>{
        'email': userId,
        'password': userKey,
        'username': name,
        'avatar_url': avatarUrl,
        'extras': extras,
      };

  @override
  Tuple2<String, QAccount> format(Json json) {
    var token = (json['results'] as Map)['user']['token'] as String;
    var user = accountFromJson((json['results'] as Map)['user'] as Json);

    return Tuple2(token, user);
  }
}

class AuthenticateWithTokenRequest
    extends IApiRequest<Tuple2<String, QAccount>> {
  AuthenticateWithTokenRequest({
    required this.identityToken,
  });

  final String identityToken;

  @override
  String get url => 'auth/verify_identity_token';

  @override
  IRequestMethod get method => IRequestMethod.post;

  @override
  Json get body => <String, dynamic>{
        'identity_token': identityToken,
      };

  @override
  Tuple2<String, QAccount> format(Json json) {
    var token = (json['results'] as Map)['user']['token'] as String;
    var user = accountFromJson((json['results'] as Map)['user'] as Json);

    return Tuple2(token, user);
  }
}
