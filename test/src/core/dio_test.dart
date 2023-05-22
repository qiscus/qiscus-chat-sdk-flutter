import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/domains.dart';
import 'package:test/test.dart';

void main() {
  late Storage s;
  late Logger l;
  late Dio d;

  void setDio() {
    d = getDio.run(Tuple2(s, l));
  }

  setUp(() {
    s = Storage();
    l = Logger(s);
    setDio();
  });

  test('dio test', () {
    var s = Storage();
    var l = Logger(s);
    var d = getDio.run(Tuple2(s, l));
    expect(d.interceptors.length, 2);

    s = Storage();
    s.debugEnabled = true;
    s.logLevel = QLogLevel.verbose;
    l = Logger(s);
    d = getDio.run(Tuple2(s, l));
    expect(d.interceptors.length, 3);
  });

  test('dio auth interceptor', () {
    var s = Storage();
    var l = Logger(s);
    var d = getDio.run(Tuple2(s, l));
    var authInterceptors = d.interceptors.first;

    var o1 = RequestOptions(path: '/');
    var h1 = Handler((options) {
      expect(options.headers.length, 5);
      expect(options.headers['qiscus-sdk-app-id'], isNull);
      expect(options.headers['qiscus-sdk-user-id'], isNull);
      expect(options.headers['qiscus-sdk-device-brand'], 'macos');
      expect(options.headers['qiscus-sdk-os-version'], isNull);
    });
    authInterceptors.onRequest(o1, h1);

    s.appId = 'some-appId';
    s.currentUser = QAccount(id: 'user-id', name: 'user-name');
    s.token = 'some-token';
    var h2 = Handler((o) {
      expect(o.headers['qiscus-sdk-app-id'], 'some-appId');
      expect(o.headers['qiscus-sdk-user-id'], 'user-id');
      expect(o.headers['qiscus-sdk-token'], 'some-token');
    });
    authInterceptors.onRequest(o1, h2);

    var o2 = RequestOptions(path: '/', queryParameters: {
      'val1': 1,
      'val2': 2,
      'val3': [1, 2, 3],
    });
    var h3 = Handler((o) {
      expect(o.queryParameters.length, 0);
      expect(o.path, contains('val1=1&val2=2'));
      expect(o.path, contains('val3[]=1&val3[]=2&val3[]=3'));
    });
    authInterceptors.onRequest(o2, h3);
  });

  test('custom headers', () {
    var s = Storage();
    var l = Logger(s);
    s.customHeaders = {
      'x-header-1': '1',
      'x-header-2': '2',
    };
    var d = getDio.run(Tuple2(s, l));

    var o1 = RequestOptions(path: '/');
    var h1 = Handler((o) {
      expect(o.headers['x-header-1'], '1');
      expect(o.headers['x-header-2'], '2');
    });
    var interceptor = d.interceptors.first;
    interceptor.onRequest(o1, h1);
  });
}

class Handler extends RequestInterceptorHandler {
  Handler(this.onNext);

  final void Function(RequestOptions options) onNext;

  @override
  void next(RequestOptions requestOptions) => onNext(requestOptions);
}
