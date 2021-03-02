import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/features/app_config/app_config.dart';
import 'package:qiscus_chat_sdk/src/type_utils.dart';
import 'package:test/test.dart';

void main() {
  Storage storage;
  setUp(() {
    storage = Storage();
  });

  test('AppConfig.hydrateStorage', () {
    var appConfig = AppConfig(
      baseUrl: Option.some('base-url'),
      brokerLbUrl: Option.some('broker-lb-url'),
      brokerUrl: Option.some('broker-url'),
      enableEventReport: Option.some(true),
      enableRealtime: Option.some(true),
      enableRealtimeCheck: Option.some(true),
      extras: Option.some(<String, dynamic>{'key': 1}),
      syncInterval: Option.some(1000),
      syncOnConnect: Option.some(123),
    );

    appConfig.hydrateStorage(storage);

    expect(Option.some(storage.baseUrl), appConfig.baseUrl);
    expect(Option.some(storage.brokerLbUrl), appConfig.brokerLbUrl);
    expect(
        Option.some(storage.brokerUrl), appConfig.brokerUrl.map((it) => '$it'));
    expect(Option.some(storage.enableEventReport), appConfig.enableEventReport);
    expect(Option.some(storage.isRealtimeEnabled), appConfig.enableRealtime);
    expect(Option.some(storage.configExtras), appConfig.extras);
    expect(Option.some(storage.isRealtimeCheckEnabled),
        appConfig.enableRealtimeCheck);
    expect(
      Option.some(storage.syncInterval.inMilliseconds),
      appConfig.syncInterval,
    );
    expect(
      Option.some(storage.syncIntervalWhenConnected.inMilliseconds),
      appConfig.syncOnConnect,
    );
  });
}
