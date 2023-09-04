import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/app_config/app_config.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:test/test.dart';

void main() {
  test('api request', () async {
    var api = GetConfigRequest();

    expect(api.method, IRequestMethod.get);
    expect(api.url, 'config');
    expect(api.body, null);
    expect(api.params, null);
  });

  test('api parse', () {
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

    expect(c.baseUrl, Some('https://api3.qiscus.com'));
    expect(c.brokerLbUrl, Some('https://realtime-lb-bali.qiscus.com'));
    expect(c.brokerUrl, Some('realtime-bali.qiscus.com'));
    expect(c.enableEventReport, Some(false));
    expect(c.enableRealtime, Some(true));
    expect(c.enableRealtimeCheck, Some(false));
    expect(c.extras, None());
    expect(c.syncInterval, Some(5000));
    expect(c.syncOnConnect, Some(30000));
  });

  test('api parse json extras', () {
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
        'extras': '{ "status": true }',
        'status': 'Success',
        'sync_interval': 5000,
        'sync_on_connect': 30000
      },
      'status': 200
    });

    expect(c.baseUrl, Some('https://api3.qiscus.com'));
    expect(c.brokerLbUrl, Some('https://realtime-lb-bali.qiscus.com'));
    expect(c.brokerUrl, Some('realtime-bali.qiscus.com'));
    expect(c.enableEventReport, Some(false));
    expect(c.enableRealtime, Some(true));
    expect(c.enableRealtimeCheck, Some(false));
    // expect(c.extras, Some(<String, Object?>{'status': true}));
    expect(c.extras.map((v) => v['status']), equals(Some(true)));
    expect(c.syncInterval, Some(5000));
    expect(c.syncOnConnect, Some(30000));
  });
}
