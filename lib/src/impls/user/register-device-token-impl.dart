import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';

RTE<bool> registerDeviceTokenImpl(String token, [bool? isDevelopment]) {
  return Reader((dio) {
    return tryCatch(() async {
      var req = SetDeviceTokenRequest(
        token: token,
        isDevelopment: isDevelopment ?? false,
      );
      return req(dio);
    });
  });
}

RTE<bool> unregisterDeviceTokenImpl(
  String token, [
  bool? isDevelopment = false,
]) {
  return Reader((dio) {
    return tryCatch(() async {
      var req = UnsetDeviceTokenRequest(
        token: token,
        isDevelopment: isDevelopment ?? false,
      );
      return req(dio);
    });
  });
}

class SetDeviceTokenRequest extends IApiRequest<bool> {
  SetDeviceTokenRequest({
    required this.token,
    this.isDevelopment = false,
    this.platform = 'flutter',
  });
  final String token;
  final bool isDevelopment;
  final String platform;

  @override
  String get url => 'set_user_device_token';

  @override
  IRequestMethod get method => IRequestMethod.post;

  @override
  Map<String, dynamic> get body => <String, dynamic>{
        'device_token': token,
        'is_development': isDevelopment,
        'device_platform': platform,
      };

  @override
  bool format(Map<String, dynamic> json) {
    return json['results']['changed'] as bool;
  }
}

class UnsetDeviceTokenRequest extends IApiRequest<bool> {
  UnsetDeviceTokenRequest({
    required this.token,
    this.isDevelopment = false,
    this.platform = 'flutter',
  });
  final String token;
  final bool isDevelopment;
  final String platform;

  @override
  String get url => 'remove_user_device_token';

  @override
  IRequestMethod get method => IRequestMethod.post;

  @override
  Map<String, dynamic> get body => <String, dynamic>{
        'device_token': token,
        'is_development': isDevelopment,
        'device_platform': platform,
      };

  @override
  bool format(Map<String, dynamic> json) {
    return json['results']['success'] as bool;
  }
}
