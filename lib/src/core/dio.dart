part of qiscus_chat_sdk.core;

Reader<Tuple2<Storage, Logger>, Dio> getDio =
    Reader((Tuple2<Storage, Logger> r) {
  var s = r.first;
  var l = r.second;

  final interceptor = InterceptorsWrapper(
    onRequest: (request, handler) {
      request.baseUrl = '${s.baseUrl}/api/v2/mobile/';
      request.headers['qiscus-sdk-app-id'] = s.appId;
      request.headers['qiscus-sdk-version'] = '$sdkPlatformName-$sdkVersion';
      request.headers['qiscus-sdk-device-brand'] = Platform.operatingSystem;
      request.headers['qiscus-sdk-device-os-version'] =
          Platform.operatingSystemVersion;

      if (request.queryParameters.isNotEmpty) {
        var qp = <String>[];
        for (var entry in request.queryParameters.entries) {
          if (entry.value is List) {
            for (var item in entry.value) {
              qp.add('${entry.key}[]=$item');
            }
          } else {
            qp.add('${entry.key}=${entry.value}');
          }
        }
        request.path += '?';
        request.path += qp.join('&');
        request.queryParameters = <String, Object?>{};
      }

      var uri = request.uri;
      print('uri query params all: ${uri.queryParametersAll}');
      print('uri query params: ${uri.queryParameters}');
      print('uri query: ${uri.query}');

      if (s.token != null) {
        request.headers['qiscus-sdk-token'] = s.token;
        request.headers['qiscus-sdk-user-id'] = s.userId;
      }
      if (s.customHeaders.isNotEmpty == true) {
        request.headers.addAll(s.customHeaders);
      }
      handler.next(request);
    },
  );
  var curl = InterceptorsWrapper(
    onRequest: (request, handler) {
      l.log('QiscusSDK ->: ${dio2curl(request)}');
      return handler.next(request);
    },
  );
  var dio = Dio(BaseOptions())
    ..interceptors.addAll([
      interceptor,
      curl,
    ]);

  if (l.enabled && l.level == QLogLevel.verbose) {
    dio.interceptors.add(PrettyDioLogger(
      requestBody: true,
      requestHeader: true,
      responseBody: true,
    ));
  }
  return dio;
});
