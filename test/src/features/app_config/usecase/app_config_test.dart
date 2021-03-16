import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/app_config/app_config.dart';
import 'package:qiscus_chat_sdk/src/type_utils.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

class MockRepo extends Mock implements AppConfigRepository {}

void main() {
  Storage s;
  AppConfigRepository repo;
  AppConfigUseCase useCase;

  setUp(() {
    s = Storage();
    repo = MockRepo();
    useCase = AppConfigUseCase(repo, s);
  });
  test('successfully get app config', () async {
    var c = AppConfig(
      baseUrl: Option.some('base-url'),
      brokerLbUrl: Option.some('broker-lb-url'),
      brokerUrl: Option.some('broker-url'),
      enableEventReport: Option.some(true),
      enableRealtime: Option.some(true),
      enableRealtimeCheck: Option.some(true),
      extras: Option.some(<String, dynamic>{'key': 1}),
      syncInterval: Option.some(1000),
      syncOnConnect: Option.some(12000),
    );
    when(repo.getConfig()).thenAnswer((_) => Future.value(c));

    var r = await useCase.call(noParams);

    expect(r.baseUrl, c.baseUrl);
    expect(r.brokerLbUrl, c.brokerLbUrl);
    expect(r.brokerUrl, c.brokerUrl);
    expect(r.enableEventReport, c.enableEventReport);
    expect(r.enableRealtime, c.enableRealtime);
    expect(r.enableRealtimeCheck, c.enableRealtimeCheck);
    expect(r.extras, c.extras);
    expect(r.syncInterval, c.syncInterval);
    expect(r.syncOnConnect, c.syncOnConnect);

    expect(s.baseUrl, 'base-url');
    expect(s.brokerLbUrl, 'broker-lb-url');
    expect(s.brokerUrl, 'broker-url');
    expect(s.enableEventReport, true);
    expect(s.isRealtimeEnabled, true);
    expect(s.isRealtimeCheckEnabled, true);
    expect(s.configExtras.keys.length, 1);
    expect(s.configExtras['key'], 1);
    expect(s.syncInterval, 1.seconds);
    expect(s.syncIntervalWhenConnected, 12.seconds);
  });
}
