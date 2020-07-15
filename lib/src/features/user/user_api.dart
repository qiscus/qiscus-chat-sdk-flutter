import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/account.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/user.dart';
import 'package:retrofit/retrofit.dart';

part 'user_api.g.dart';

@immutable
@JsonSerializable()
class AuthenticateRequest extends Equatable {
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

  @override
  List<Object> get props => [email, password];
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
    return AuthenticateResponse(token, user);
  }
  AuthenticateResponse(this.token, this.user);
}

@immutable
@JsonSerializable()
class AuthenticateWithTokenRequest extends Equatable {
  @JsonKey(name: 'identity_token')
  final String identityToken;
  const AuthenticateWithTokenRequest(this.identityToken);

  Map<String, dynamic> toJson() => _$AuthenticateWithTokenRequestToJson(this);

  @override
  List<Object> get props => [identityToken];
}

@immutable
@JsonSerializable()
class BlockUserRequest extends Equatable {
  @JsonKey(name: 'user_email')
  final String userId;
  const BlockUserRequest(this.userId);

  Map<String, dynamic> toJson() => _$BlockUserRequestToJson(this);
  @override
  List<Object> get props => [userId];
}

@immutable
@JsonSerializable()
class DeviceTokenRequest extends Equatable {
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

  @override
  List<Object> get props => [token, platform];
}

@immutable
class GetNonceResponse {
  final String nonce;
  factory GetNonceResponse.fromJson(Map<String, dynamic> json) {
    var nonce = json['results']['nonce'] as String;
    return GetNonceResponse(nonce);
  }
  GetNonceResponse(this.nonce);
}

@immutable
class GetUserResponse {
  final Account user;
  factory GetUserResponse.fromJson(Map<String, dynamic> json) {
    var user = Account.fromJson(
      json['results']['user'] as Map<String, dynamic>,
    );
    return GetUserResponse(user);
  }
  GetUserResponse(this.user);
}

@immutable
@JsonSerializable()
class UpdateUserRequest extends Equatable {
  final String name;
  @JsonKey(name: 'avatar_url')
  final String avatarUrl;
  final Map<String, dynamic> extras;
  const UpdateUserRequest({this.name, this.avatarUrl, this.extras});

  Map<String, dynamic> toJson() => _$UpdateUserRequestToJson(this);
  @override
  List<Object> get props => [name, avatarUrl, extras];
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
    }).toList();
    return UsersResponse(users_);
  }

  UsersResponse(this.users);
}
