import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import 'package:qiscus_chat_sdk/src/core.dart';

ReaderTaskEither<Dio, QError, String> getNonceImpl() {
  return Reader((dio) {
    return tryCatch(() async {
      var req = GetNonceRequest();
      return req.call(dio);
    });
  });
}

class GetNonceRequest extends IApiRequest<String> {
  @override
  String get url => 'auth/nonce';
  @override
  IRequestMethod get method => IRequestMethod.post;

  @override
  String format(Json json) {
    return (json['results'] as Map)['nonce'] as String;
  }
}
