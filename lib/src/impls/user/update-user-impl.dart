import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/user/user-model.dart';

import 'account-from-json.dart';

RTE<State<Storage, QAccount>> updateUserImpl({
  String? name,
  String? avatarUrl,
  Json? extras,
}) {
  return tryCR((dio) async {
    var req = UpdateUserDataRequest(
      name: name,
      avatarUrl: avatarUrl,
      extras: extras,
    );
    var account = await req(dio);

    return State((Storage s) {
      s.currentUser = account;
      return Tuple2(account, s);
    });
  });
}

class UpdateUserDataRequest extends IApiRequest<QAccount> {
  UpdateUserDataRequest({
    this.name,
    this.avatarUrl,
    this.extras,
  });
  final String? name;
  final String? avatarUrl;
  final Json? extras;

  @override
  String get url => 'my_profile';

  @override
  IRequestMethod get method => IRequestMethod.patch;

  @override
  Json get body => <String, dynamic>{
        'name': name,
        'avatar_url': avatarUrl,
        'extras': extras,
      };

  @override
  QAccount format(Json json) {
    return accountFromJson((json['results'] as Map)['user'] as Json);
  }
}
