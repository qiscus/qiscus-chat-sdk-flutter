import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/user/user-model.dart';
import 'package:qiscus_chat_sdk/src/impls/user/user-from-json-impl.dart';

ReaderTaskEither<Dio, String, Iterable<QUser>> getBlockedUsersImpl({
  int? page,
  int? limit,
}) {
  return Reader((dio) {
    return TaskEither.tryCatch(() async {
      var req = GetBlockedUsersRequest(page: page, limit: limit);
      return req(dio);
    }, (e, _) => e.toString());
  });
}

class GetBlockedUsersRequest extends IApiRequest<Iterable<QUser>> {
  const GetBlockedUsersRequest({
    required this.page,
    required this.limit,
  });
  final int? page;
  final int? limit;

  @override
  String get url => 'get_blocked_users';
  @override
  IRequestMethod get method => IRequestMethod.get;
  @override
  Json get params => <String, dynamic>{
        'page': page,
        'limit': limit,
      };

  @override
  Iterable<QUser> format(Json json) sync* {
    var blockedUsers = (json['results'] as Map)['blocked_users'] as List;

    for (var item in blockedUsers.cast<Json>()) {
      yield userFromJson(item);
    }
  }
}
