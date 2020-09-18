import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/features/app_config/app_config.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';

class MockDio extends Mock implements Dio {}

void main() async {
  Dio dio;
  GetConfigRequest api;

  setUp(() {
    dio = MockDio();
    api = GetConfigRequest();
  });

  test('has correct method', () {
    expect(api.method, IRequestMethod.get);
  });

  test('has correct url', () {
    expect(api.url, 'config');
  });

  test('format', () {
    final json = <String, dynamic>{
      'results': {
        'base_url': 'https://api3.qiscus.com',
        'broker_lb_url': 'https://realtime-lb.qiscus.com',
        'broker_url': 'realtime-jogja.qiscus.com',
        'enable_event_report': false,
        'enable_realtime': true,
        'enable_realtime_check': false,
        'extras': '',
        'sync_interval': 5000,
        'sync_on_connect': 30000
      },
      'status': 200
    };
    var result = api.format(json);

    var extras = decodeJson(json['results']['extras']);

    expect(result.baseUrl, some(json['results']['base_url'] as String));
    expect(result.brokerLbUrl, some(json['results']['broker_lb_url'] as String));
    expect(result.brokerUrl, some(json['results']['broker_url'] as String));
    expect(result.enableEventReport, some(json['results']['enable_event_report'] as bool));
    expect(result.enableRealtime, some(json['results']['enable_realtime'] as bool));
    expect(result.enableRealtimeCheck, some(json['results']['enable_realtime_check'] as bool));
    expect(result.extras, extras);
    expect(result.syncInterval, some(json['results']['sync_interval'] as int));
    expect(result.syncOnConnect, some(json['results']['sync_on_connect'] as int));
  });
}
