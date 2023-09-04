import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/user/user-model.dart';
import 'package:qiscus_chat_sdk/src/impls/user/user-from-json-impl.dart';

RTE<Iterable<QUser>> getUsersImpl({
  String? query,
  int? page,
  int? limit,
}) {
  return Reader((dio) {
    return tryCatch(() async {
      return GetUserListRequest(
        query: query,
        page: page,
        limit: limit,
      )(dio);
    });
  });
}

class GetUserListRequest extends IApiRequest<Iterable<QUser>> {
  const GetUserListRequest({
    required this.query,
    required this.page,
    required this.limit,
  });
  final String? query;
  final int? page;
  final int? limit;

  @override
  String get url => 'get_user_list';
  @override
  IRequestMethod get method => IRequestMethod.get;
  @override
  Json get body => <String, dynamic>{
        'page': page,
        'limit': limit,
        'query': query,
      };

  @override
  Iterable<QUser> format(Json json) sync* {
    var users = (json['results'] as Map)['users'] as List;
    for (var json in users.cast<Json>()) {
      yield userFromJson(json);
    }
  }
}
