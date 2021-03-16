part of qiscus_chat_sdk.usecase.app_config;

class AppConfigRepository {
  const AppConfigRepository({@required this.dio});

  final Dio dio;

  Future<AppConfig> getConfig() {
    final request = GetConfigRequest();
    return dio.sendApiRequest(request).then(request.format);
  }
}
