part of qiscus_chat_sdk.core;

Dio getDio(Storage storage, Logger logger) {
  final interceptor = InterceptorsWrapper(
    onRequest: (request, handler) {
      request.baseUrl = '${storage?.baseUrl}/api/v2/mobile/';
      request.headers['qiscus-sdk-app-id'] = storage.appId;
      request.headers['qiscus-sdk-version'] = '$sdkPlatformName-$sdkVersion';
      request.headers['qiscus-sdk-device-brand'] = Platform.operatingSystem;
      request.headers['qiscus-sdk-device-os-version'] =
          Platform.operatingSystemVersion;

      if (storage?.token != null) {
        request.headers['qiscus-sdk-token'] = storage.token;
        request.headers['qiscus-sdk-user-id'] = storage.userId;
      }
      if (storage?.customHeaders?.isNotEmpty == true) {
        request.headers.addAll(storage.customHeaders);
      }
      handler.next(request);
    },
  );
  var curl = InterceptorsWrapper(
    onRequest: (request, handler) {
      logger.log('QiscusSDK ->: ${dio2curl(request)}');
      return handler.next(request);
    },
  );
  var dio = Dio(BaseOptions())
    ..interceptors.addAll([
      interceptor,
      curl,
    ]);

  if (logger.enabled && logger.level == QLogLevel.verbose) {
    dio.interceptors.add(PrettyDioLogger(
      requestBody: true,
      requestHeader: true,
    ));
  }
  return dio;
}
