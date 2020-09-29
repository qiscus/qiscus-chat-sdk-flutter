import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/realtime.dart';
import 'package:test/test.dart';

class MockStorage extends Mock implements Storage {}

class MockService extends Mock implements IRealtimeService {}

void main() {
  Storage storage;
  IRealtimeService mqtt;
  Interval interval;

  setUp(() {
    storage = Storage();
    mqtt = MockService();

    interval = Interval(storage, mqtt);
  });

  test('should not producing event if not started', () async {
    // when(storage.accSyncInterval).thenReturn(100.milliseconds);
    // when(storage.syncInterval).thenReturn(100.milliseconds);
    // when(storage.syncIntervalWhenConnected).thenReturn(100.milliseconds);
    storage
      ..accSyncInterval = 1.milliseconds
      ..syncInterval = 100.milliseconds
      ..syncIntervalWhenConnected = 100.milliseconds;

    when(mqtt.isConnected).thenReturn(false);

    var buffer = <int>[];

    StreamSubscription<int> subs;

    Future<void>.delayed(2.seconds, () async {
      await subs?.cancel();

      expect(buffer.length, 0);
    });

    subs = interval
        .interval() //
        .map((_) => buffer.length + 1)
        .listen((data) => buffer.add(data));

    // verifyNever(storage.accSyncInterval).called(0);
    // verify(storage.syncInterval).called(1);
    // verifyNever(storage.syncIntervalWhenConnected);
    // verify(mqtt.isConnected).called(1);
  });
}
