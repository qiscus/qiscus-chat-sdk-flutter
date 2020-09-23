import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';
import 'package:test/test.dart';
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';

void main() {
  Storage storage;
  Logger logger;

  setUp(() {
    storage = Storage();
    logger = Logger(storage);
  });

  test('successfully create dio instance', () async {
    storage.baseUrl = 'base-url';
    storage.appId = 'app-id';
    storage.token = 'token';
    storage.currentUser = Account(
      id: 'user-id',
    );

    var dio = getDio(storage, logger);

    // dio.interceptors.forEach((element) {});
    expect(dio.interceptors.length, 1);
    var interceptor = dio.interceptors.first;
    var options = RequestOptions();
    options = (await interceptor.onRequest(options)) as RequestOptions;

    expect(options.baseUrl, 'base-url/api/v2/mobile/');
    expect(options.headers['qiscus-sdk-app-id'], 'app-id');
    expect(options.headers['qiscus-sdk-token'], 'token');
    expect(options.headers['qiscus-sdk-user-id'], 'user-id');
    expect(options.headers['qiscus-sdk-version'], '$sdkPlatformName-$sdkVersion');
  });
  test('has 2 interceptor if debug enabled', () async {
    storage.debugEnabled = true;
    var dio = getDio(storage, logger);

    expect(dio.interceptors.length, 2);
  });
}
