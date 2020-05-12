import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/account.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/user.dart';
import 'package:retrofit/retrofit.dart';

part 'user_api.g.dart';

@immutable
@JsonSerializable()
class AuthenticateRequest {
  final String email, password, username, avatar_url;
  final Map<String, dynamic> extras;
  AuthenticateRequest(
    this.email,
    this.password, {
    this.username,
    this.avatar_url,
    this.extras,
  });

  factory AuthenticateRequest.fromJson(Map<String, dynamic> json) =>
      _$AuthenticateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AuthenticateRequestToJson(this);
}

@immutable
class AuthenticateResponse {
  final Account user;
  final String token;
  factory AuthenticateResponse.fromJson(Map<String, dynamic> json) {
    var token = json['results']['user']['token'] as String;
    var user = Account.fromJson(
      json['results']['user'] as Map<String, dynamic>,
    );
    return AuthenticateResponse._(token, user);
  }
  AuthenticateResponse._(this.token, this.user);
}

@immutable
@JsonSerializable()
class AuthenticateWithTokenRequest {
  final String identity_token;
  const AuthenticateWithTokenRequest(this.identity_token);

  Map<String, dynamic> toJson() => _$AuthenticateWithTokenRequestToJson(this);
}

@immutable
@JsonSerializable()
class BlockUserRequest {
  @JsonKey(name: 'user_email')
  final String user_id;
  const BlockUserRequest(this.user_id);

  Map<String, dynamic> toJson() => _$BlockUserRequestToJson(this);
}

@immutable
@JsonSerializable()
class DeviceTokenRequest {
  @JsonKey(name: 'device_token')
  final String token;

  @JsonKey(name: 'is_development', nullable: true)
  final bool is_development;

  @JsonKey(name: 'device_platform', defaultValue: 'rn')
  final String platform;

  const DeviceTokenRequest(
    this.token, [
    this.is_development = false,
    this.platform = 'rn',
  ]);

  Map<String, dynamic> toJson() => _$DeviceTokenRequestToJson(this);
}

@immutable
class GetNonceResponse {
  final String nonce;
  factory GetNonceResponse.fromJson(Map<String, dynamic> json) {
    var nonce = json['results']['nonce'] as String;
    return GetNonceResponse._(nonce);
  }
  GetNonceResponse._(this.nonce);
}

@immutable
class GetUserResponse {
  final Account user;
  factory GetUserResponse.fromJson(Map<String, dynamic> json) {
    var user = Account.fromJson(
      json['results']['user'] as Map<String, dynamic>,
    );
    return GetUserResponse._(user);
  }
  GetUserResponse._(this.user);
}

@immutable
@JsonSerializable()
class UpdateUserRequest {
  final String name;
  final String avatar_url;
  final Map<String, dynamic> extras;
  const UpdateUserRequest({this.name, this.avatar_url, this.extras});

  Map<String, dynamic> toJson() => _$UpdateUserRequestToJson(this);
}

@RestApi()
abstract class UserApi {
  factory UserApi(Dio dio) = _UserApi;

  @POST('login_or_register')
  Future<AuthenticateResponse> authenticate(
    @Body() AuthenticateRequest request,
  );

  @POST('auth/verify_identity_token')
  Future<AuthenticateResponse> authenticateWithToken(
    @Body() AuthenticateWithTokenRequest request,
  );

  @POST('block_user')
  Future<User> blockUser(
    @Body() BlockUserRequest request,
  );

  @GET('get_blocked_users')
  Future<List<User>> getBlockedUsers({
    @Query('page') int page,
    @Query('limit') int limit,
  });

  @POST('auth/nonce')
  Future<GetNonceResponse> getNonce();

  @GET('my_profile')
  Future<GetUserResponse> getUserData();

  @GET('get_user_list')
  Future<UsersResponse> getUsers({
    @Query('query') String query,
    @Query('page') int page,
    @Query('limit') int limit,
  });

  @POST('set_user_device_token', autoCastResponse: false)
  Future<String> registerDeviceToken(@Body() DeviceTokenRequest request);

  @POST('unblock_user')
  Future<User> unblockUser(
    @Body() BlockUserRequest request,
  );

  @POST('remove_user_device_token', autoCastResponse: false)
  Future<String> unregisterDeviceToken(@Body() DeviceTokenRequest request);

  @PATCH('my_profile', autoCastResponse: false)
  Future<String> updateUser(@Body() UpdateUserRequest request);
}

@immutable
class UsersResponse {
  final List<User> users;
  factory UsersResponse.fromJson(Map<String, dynamic> json) {
    var users = json['results']['users'] as List;
    var users_ = users.cast<Map<String, dynamic>>().map((it) {
      return User.fromJson(it);
    }).toList(growable: false);
    return UsersResponse._(users_);
  }

  UsersResponse._(this.users);
}
