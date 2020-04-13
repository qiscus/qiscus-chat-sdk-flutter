// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthenticateRequest _$AuthenticateRequestFromJson(Map<String, dynamic> json) {
  return AuthenticateRequest(
    json['email'] as String,
    json['password'] as String,
    username: json['username'] as String,
    avatar_url: json['avatar_url'] as String,
    extras: json['extras'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$AuthenticateRequestToJson(
        AuthenticateRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'username': instance.username,
      'avatar_url': instance.avatar_url,
      'extras': instance.extras,
    };

AuthenticateWithTokenRequest _$AuthenticateWithTokenRequestFromJson(
    Map<String, dynamic> json) {
  return AuthenticateWithTokenRequest(
    json['identity_token'] as String,
  );
}

Map<String, dynamic> _$AuthenticateWithTokenRequestToJson(
        AuthenticateWithTokenRequest instance) =>
    <String, dynamic>{
      'identity_token': instance.identity_token,
    };

BlockUserRequest _$BlockUserRequestFromJson(Map<String, dynamic> json) {
  return BlockUserRequest(
    json['user_email'] as String,
  );
}

Map<String, dynamic> _$BlockUserRequestToJson(BlockUserRequest instance) =>
    <String, dynamic>{
      'user_email': instance.user_id,
    };

DeviceTokenRequest _$DeviceTokenRequestFromJson(Map<String, dynamic> json) {
  return DeviceTokenRequest(
    json['device_token'] as String,
    json['is_development'] as bool,
  );
}

Map<String, dynamic> _$DeviceTokenRequestToJson(DeviceTokenRequest instance) =>
    <String, dynamic>{
      'device_token': instance.token,
      'is_development': instance.is_development,
    };

UpdateUserRequest _$UpdateUserRequestFromJson(Map<String, dynamic> json) {
  return UpdateUserRequest(
    name: json['name'] as String,
    avatar_url: json['avatar_url'] as String,
    extras: json['extras'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$UpdateUserRequestToJson(UpdateUserRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'avatar_url': instance.avatar_url,
      'extras': instance.extras,
    };

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _UserApi implements UserApi {
  _UserApi(this._dio, {this.baseUrl}) {
    ArgumentError.checkNotNull(_dio, '_dio');
  }

  final Dio _dio;

  String baseUrl;

  @override
  authenticate(request) async {
    ArgumentError.checkNotNull(request, 'request');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request?.toJson() ?? <String, dynamic>{});
    final Response<Map<String, dynamic>> _result = await _dio.request(
        'login_or_register',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = AuthenticateResponse.fromJson(_result.data);
    return Future.value(value);
  }

  @override
  authenticateWithToken(request) async {
    ArgumentError.checkNotNull(request, 'request');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request?.toJson() ?? <String, dynamic>{});
    final Response<Map<String, dynamic>> _result = await _dio.request(
        'auth/verify_identity_token',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = AuthenticateResponse.fromJson(_result.data);
    return Future.value(value);
  }

  @override
  blockUser(request) async {
    ArgumentError.checkNotNull(request, 'request');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request?.toJson() ?? <String, dynamic>{});
    final Response<Map<String, dynamic>> _result = await _dio.request(
        'block_user',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = User.fromJson(_result.data);
    return Future.value(value);
  }

  @override
  getBlockedUsers({page, limit}) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{'page': page, 'limit': limit};
    queryParameters.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    final Response<List<dynamic>> _result = await _dio.request(
        'get_blocked_users',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    var value = _result.data
        .map((dynamic i) => User.fromJson(i as Map<String, dynamic>))
        .toList();
    return Future.value(value);
  }

  @override
  getNonce() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final Response<Map<String, dynamic>> _result = await _dio.request(
        'auth/nonce',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = GetNonceResponse.fromJson(_result.data);
    return Future.value(value);
  }

  @override
  getUserData() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final Response<Map<String, dynamic>> _result = await _dio.request(
        'my_profile',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = GetUserResponse.fromJson(_result.data);
    return Future.value(value);
  }

  @override
  getUsers({query, page, limit}) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      'query': query,
      'page': page,
      'limit': limit
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    final Response<Map<String, dynamic>> _result = await _dio.request(
        'get_user_list',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = UsersResponse.fromJson(_result.data);
    return Future.value(value);
  }

  @override
  registerDeviceToken(request) async {
    ArgumentError.checkNotNull(request, 'request');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request?.toJson() ?? <String, dynamic>{});
    final Response<bool> _result = await _dio.request('set_user_device_token',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = _result.data;
    return Future.value(value);
  }

  @override
  unblockUser(request) async {
    ArgumentError.checkNotNull(request, 'request');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request?.toJson() ?? <String, dynamic>{});
    final Response<Map<String, dynamic>> _result = await _dio.request(
        'unblock_user',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = User.fromJson(_result.data);
    return Future.value(value);
  }

  @override
  unregisterDeviceToken(request) async {
    ArgumentError.checkNotNull(request, 'request');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request?.toJson() ?? <String, dynamic>{});
    final Response<bool> _result = await _dio.request(
        'remove_user_device_token',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = _result.data;
    return Future.value(value);
  }

  @override
  updateUser(request) async {
    ArgumentError.checkNotNull(request, 'request');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request?.toJson() ?? <String, dynamic>{});
    final Response<Map<String, dynamic>> _result = await _dio.request(
        'my_profile',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'PATCH',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = Account.fromJson(_result.data);
    return Future.value(value);
  }
}
