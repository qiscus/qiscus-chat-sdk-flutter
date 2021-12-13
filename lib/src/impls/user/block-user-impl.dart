import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/user/user-model.dart';
import 'package:qiscus_chat_sdk/src/impls/user/user-from-json-impl.dart';

ReaderTaskEither<Dio, String, QUser> blockUserImpl(String userId) {
  return Reader((Dio dio) {
    return TaskEither.tryCatch(() async {
      var req = BlockUserRequest(userId: userId);
      return req(dio);
    }, (e, _) => e.toString());
  });
}

class BlockUserRequest extends IApiRequest<QUser> {
  BlockUserRequest({
    required this.userId,
  });
  final String userId;

  @override
  String get url => 'block_user';
  @override
  IRequestMethod get method => IRequestMethod.post;
  @override
  Map<String, dynamic> get body => <String, dynamic>{'user_email': userId};

  @override
  QUser format(Map<String, dynamic> json) {
    return userFromJson(json['results']['user'] as Map<String, dynamic>);
  }
}
