import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import 'package:qiscus_chat_sdk/src/core.dart';


ReaderTaskEither<Dio, String, String> getNonceImpl() {
  return Reader((dio) {
    return TaskEither.tryCatch(() async {
      var req = GetNonceRequest();
      return req(dio);
    }, (e, _) => e.toString());
  });
}


class GetNonceRequest extends IApiRequest<String> {
  @override
  String get url => 'auth/nonce';
  @override
  IRequestMethod get method => IRequestMethod.post;

  @override
  String format(Map<String, dynamic> json) {
    return json['results']['nonce'] as String;
  }
}
