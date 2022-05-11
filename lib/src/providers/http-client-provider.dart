import 'dart:io';

import 'package:qiscus_chat_sdk/src/providers/commons.dart';
import 'package:qiscus_chat_sdk/src/providers/states.dart';
import 'package:riverpod/riverpod.dart';
import 'package:dio/dio.dart';

final requestInterceptorProvider = Provider((ref) {
  var baseUrl = ref.watch(baseUrlProvider);
  var appId = ref.watch(appIdProvider);
  var platformName = 'flutter';
  var sdkVersion = ref.watch(sdkVersionProvider);

  var interceptor = InterceptorsWrapper(
    onRequest: (request, handler) {
      request.baseUrl = '$baseUrl/api/v2/mobile/';
      request.headers['qiscus-sdk-app-id'] = appId;
      request.headers['qiscus-sdk-version'] = '$platformName-$sdkVersion';
      request.headers['qiscus-sdk-device-brand'] = Platform.operatingSystem;
      request.headers['qiscus-sdk-device-os-version'] =
          Platform.operatingSystemVersion;

      return handler.next(request);
    },
  );

  return interceptor;
});

typedef RequestInterceptorFn = RequestOptions Function(
  RequestOptions,
  RequestInterceptorHandler,
);
final httpInterceptorsProvider = StateProvider<List<RequestInterceptorFn>>(
  (ref) => const [],
);

final httpClientProvider = Provider((ref) {
  var baseUrl = ref.watch(baseUrlProvider);
  var requestInterceptor = ref.watch(requestInterceptorProvider);

  var dio = Dio(BaseOptions(
    baseUrl: baseUrl,
  ));

  dio.interceptors.add(requestInterceptor);

  return dio;
});
