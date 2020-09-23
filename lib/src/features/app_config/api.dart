part of qiscus_chat_sdk.usecase.app_config;

class GetConfigRequest extends IApiRequest<AppConfig> {
  IRequestMethod get method => IRequestMethod.get;
  String get url => 'config';

  AppConfig format(Map<String, dynamic> json) {
    return AppConfig.fromJson(json['results'] as Map<String, dynamic>);
  }
}
