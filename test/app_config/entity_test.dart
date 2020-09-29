import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/features/app_config/app_config.dart';
import 'package:test/test.dart';

void main() {
  Storage storage;
  setUp(() {
    storage = Storage();
  });

  test('AppConfig.hydrateStorage', () {
    var appConfig = AppConfig(
      baseUrl: some('base-url'),
      brokerLbUrl: some('broker-lb-url'),
      brokerUrl: some('broker-url'),
      enableEventReport: some(true),
      enableRealtime: some(true),
      enableRealtimeCheck: some(true),
      extras: some(<String, dynamic>{'key': 1}),
      syncInterval: some(1000),
      syncOnConnect: some(123),
    );

    appConfig.hydrateStorage(storage);

    expect(some(storage.baseUrl), appConfig.baseUrl);
    expect(some(storage.brokerLbUrl), appConfig.brokerLbUrl);
    expect(some(storage.brokerUrl),
        appConfig.brokerUrl.map((it) => 'wss://$it:1886/mqtt'));
    expect(some(storage.enableEventReport), appConfig.enableEventReport);
    expect(some(storage.isRealtimeEnabled), appConfig.enableRealtime);
    expect(some(storage.configExtras), appConfig.extras);
    expect(some(storage.isRealtimeCheckEnabled), appConfig.enableRealtimeCheck);
    expect(
      some(storage.syncInterval.inMilliseconds),
      appConfig.syncInterval,
    );
    expect(
      some(storage.syncIntervalWhenConnected.inMilliseconds),
      appConfig.syncOnConnect,
    );
  });
}
