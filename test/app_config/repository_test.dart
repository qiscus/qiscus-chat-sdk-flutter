import 'package:qiscus_chat_sdk/src/features/app_config/app_config.dart';
import 'package:qiscus_chat_sdk/src/type_utils.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';

class MockDio extends Mock implements Dio {}

void main() {
  Dio dio;
  AppConfigRepository repo;

  setUp(() {
    dio = MockDio();
    repo = AppConfigRepository(dio: dio);
  });

  test('get app_config successfully', () async {
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
    when(dio.request<Map<String, dynamic>>(
      any,
      options: anyNamed('options'),
      cancelToken: anyNamed('cancelToken'),
      onReceiveProgress: anyNamed('onReceiveProgress'),
      queryParameters: anyNamed('queryParameters'),
      data: anyNamed('data'),
    )).thenAnswer((_) async => Response(data: json));

    var config = await repo.getConfig();

    expect(config.baseUrl, Option.some(json['results']['base_url'] as String));
    expect(config.brokerLbUrl,
        Option.some(json['results']['broker_lb_url'] as String));
    expect(
        config.brokerUrl, Option.some(json['results']['broker_url'] as String));
    expect(config.enableEventReport,
        Option.some(json['results']['enable_event_report'] as bool));
    expect(config.enableRealtime,
        Option.some(json['results']['enable_realtime'] as bool));
    expect(config.enableRealtimeCheck,
        Option.some(json['results']['enable_realtime_check'] as bool));
    expect(Option.isNone(config.extras), true);
    expect(config.syncInterval,
        Option.some(json['results']['sync_interval'] as int));
    expect(config.syncOnConnect,
        Option.some(json['results']['sync_on_connect'] as int));

    verify(dio.request<String>(
      'config',
      options: anyNamed('options'),
      data: anyNamed('data'),
      queryParameters: anyNamed('queryParameters'),
    )).called(1);

    verifyNoMoreInteractions(dio);
  });
}
