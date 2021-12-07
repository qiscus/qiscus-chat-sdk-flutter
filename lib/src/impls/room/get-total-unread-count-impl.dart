import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import 'package:qiscus_chat_sdk/src/core.dart';

RTE<int> getTotalUnreadImpl() {
  return Reader((Dio dio) {
    return tryCatch(() async {
      return GetTotalUnreadCountRequest()(dio);
    });
  });
}

class GetTotalUnreadCountRequest extends IApiRequest<int> {
  @override
  String get url => 'total_unread_count';

  @override
  IRequestMethod get method => IRequestMethod.get;

  @override
  int format(Map<String, dynamic> json) {
    return json['results']['total_unread_count'] as int;
  }
}
