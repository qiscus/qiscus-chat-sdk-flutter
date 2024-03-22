import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/user/user-model.dart';
import 'package:qiscus_chat_sdk/src/impls/user/user-from-json-impl.dart';

ReaderTaskEither<Dio, QError, QUser> unblockUserImpl(String userId) {
  return Reader((Dio dio) {
    return tryCatch(() async {
      var req = UnblockUserRequest(userId: userId);
      return req(dio);
    });
  });
}

class UnblockUserRequest extends IApiRequest<QUser> {
  const UnblockUserRequest({
    required this.userId,
  });
  final String userId;

  @override
  String get url => 'unblock_user';
  @override
  IRequestMethod get method => IRequestMethod.post;
  @override
  Json get body => <String, dynamic>{
        'user_email': userId,
      };

  @override
  QUser format(Json json) {
    return userFromJson((json['results'] as Map)['user'] as Json);
  }
}
