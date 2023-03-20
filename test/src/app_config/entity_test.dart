import 'package:qiscus_chat_sdk/src/app_config/app_config.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:test/test.dart';

void main() {
  test('appConfig hydrate', () {
    var api = GetConfigRequest();

    var c = api.format(<String, Object?>{
      'results': {
        'app_code': '',
        'base_url': 'https://api3.qiscus.com',
        'broker_lb_url': 'https://realtime-lb-bali.qiscus.com',
        'broker_url': 'realtime-bali.qiscus.com',
        'enable_event_report': false,
        'enable_realtime': true,
        'enable_realtime_check': false,
        'extras': '',
        'status': 'Success',
        'sync_interval': 5000,
        'sync_on_connect': 30000
      },
      'status': 200
    });

    var s = Storage();
    s = c.hydrate().run(s).second;

    expect(s.baseUrl, 'https://api3.qiscus.com');
    expect(s.brokerLbUrl, 'https://realtime-lb-bali.qiscus.com');
    expect(s.brokerUrl, 'realtime-bali.qiscus.com');
    expect(s.enableEventReport, false);
    expect(s.isRealtimeEnabled, true);
    expect(s.isRealtimeCheckEnabled, false);
    expect(s.configExtras, isNull);
    expect(s.syncInterval, 5000.milliseconds);
    expect(s.syncIntervalWhenConnected, 30000.milliseconds);
  });
}
