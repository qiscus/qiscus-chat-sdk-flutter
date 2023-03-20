import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/user/user-model.dart';

import 'account-from-json.dart';

RTE<State<Storage, QAccount>> getUserDataImpl() {
  return Reader((Dio dio) {
    return tryCatch(() async {
      var req = GetUserDataRequest();
      var account = await req(dio);
      return State((Storage s) {
        s.currentUser = account;
        return Tuple2(account, s);
      });
    });
  });
}

class GetUserDataRequest extends IApiRequest<QAccount> {
  @override
  String get url => 'my_profile';

  @override
  IRequestMethod get method => IRequestMethod.get;

  @override
  QAccount format(Json json) {
    return accountFromJson((json['results'] as Map)['user'] as Json);
  }
}
