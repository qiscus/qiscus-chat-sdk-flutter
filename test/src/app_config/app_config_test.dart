import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/app_config/app_config.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:test/test.dart';
import '../dio_mock.dart';

void main() {
  late MockDio dio;

  setUp(() {
    dio = MockDio();
  });

  test('AppConfig useCase', () async {
    const json = {
      'results': {
        'app_code': '',
        'base_url': 'https://api3.qiscus.com',
        'broker_lb_url': 'https://realtime-lb-bdg.qiscus.com',
        'broker_url': 'realtime-bdg.qiscus.com',
        'enable_event_report': false,
        'enable_realtime': false,
        'enable_realtime_check': false,
        'extras': '',
        'status': 'Success',
        'sync_interval': 5000,
        'sync_on_connect': 30000
      },
      'status': 200
    };
    when(dio.request(any, options: anyNamed('options')))
        .thenAnswer((_) async => Response<Map<String, Object?>>(
              data: json,
              requestOptions: RequestOptions(path: 'config'),
            ));

    var data = await appConfigUseCase.run(dio).run();

    expect(data, isA<Right>());
    var state = (data as Right).value as State<Storage, void>;

    var s = state.execute(Storage());
    expect(s.baseUrl, 'https://api3.qiscus.com');
    expect(s.brokerLbUrl, 'https://realtime-lb-bdg.qiscus.com');
    expect(s.brokerUrl, 'realtime-bdg.qiscus.com');
    expect(s.isRealtimeEnabled, false);
    expect(s.isRealtimeCheckEnabled, false);
    expect(s.configExtras, null);
    expect(s.syncInterval, const Duration(seconds: 5));
    expect(s.syncIntervalWhenConnected, const Duration(seconds: 30));

    verify(dio.request('config', options: anyNamed('options'))).called(1);

    verifyNoMoreInteractions(dio);
  });
}
