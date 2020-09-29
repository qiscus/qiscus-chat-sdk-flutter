import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/features/app_config/app_config.dart';
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
      baseUrl: some('base-url'),
      brokerLbUrl: some('broker-lb-url'),
      brokerUrl: some('broker-url'),
      enableEventReport: some(true),
      enableRealtime: some(true),
      enableRealtimeCheck: some(true),
      extras: some(<String, dynamic>{'key': 1}),
      syncInterval: some(1000),
      syncOnConnect: some(12000),
    );
    when(repo.getConfig()).thenReturn(Task(() async {
      return right(c);
    }));

    var result = await useCase.call(noParams).run();

    result.fold((err) => fail(err.message), (r) {
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
      expect(s.brokerUrl, 'wss://broker-url:1886/mqtt');
      expect(s.enableEventReport, true);
      expect(s.isRealtimeEnabled, true);
      expect(s.isRealtimeCheckEnabled, true);
      expect(s.configExtras.keys.length, 1);
      expect(s.configExtras['key'], 1);
      expect(s.syncInterval, 1.seconds);
      expect(s.syncIntervalWhenConnected, 12.seconds);
    });
  });
}
