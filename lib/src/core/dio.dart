part of qiscus_chat_sdk.core;

Dio getDio(Storage storage, Logger logger) {
  final interceptor = InterceptorsWrapper(
    onRequest: (request) {
      request.baseUrl = '${storage?.baseUrl}/api/v2/mobile/';
      request.headers['qiscus-sdk-app-id'] = storage.appId;
      request.headers['qiscus-sdk-version'] = '$sdkPlatformName-$sdkVersion';
      if (storage?.token != null) {
        request.headers['qiscus-sdk-token'] = storage.token;
        request.headers['qiscus-sdk-user-id'] = storage.userId;
      }
      return request;
    },
  );
  var dio = Dio(BaseOptions())
    ..interceptors.addAll([
      interceptor,
    ]);
  if (logger.enabled && logger.level == QLogLevel.verbose) {
    dio.interceptors.add(PrettyDioLogger(
      requestBody: true,
      requestHeader: true,
    ));
  }
  return dio;
}
