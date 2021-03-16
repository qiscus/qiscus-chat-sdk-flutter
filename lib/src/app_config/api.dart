part of qiscus_chat_sdk.usecase.app_config;

class GetConfigRequest extends IApiRequest<AppConfig> {
  @override
  IRequestMethod get method => IRequestMethod.get;
  @override
  String get url => 'config';

  @override
  AppConfig format(Map<String, dynamic> json) {
    return AppConfig.fromJson(json['results'] as Map<String, dynamic>);
  }
}
