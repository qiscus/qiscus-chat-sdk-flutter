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
  GetUserListRequest({
    this.query,
    this.page,
    this.limit,
  });
  final String? query;
  final int? page;
  final int? limit;

  @override
  String get url => 'get_user_list';
  @override
  IRequestMethod get method => IRequestMethod.get;
  @override
  Map<String, dynamic> get body => <String, dynamic>{
        'page': page,
        'limit': limit,
        'query': query,
      };

  @override
  Iterable<QUser> format(Map<String, dynamic> json) sync* {
    var users = json['results']['users'] as List;
    for (var json in users.cast<Map<String, dynamic>>()) {
      yield userFromJson(json);
    }
  }
}
