import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/realtime.dart';
import 'package:test/test.dart';

import 'package:fake_async/fake_async.dart';

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
    storage
      ..accSyncInterval = 1.milliseconds
      ..syncInterval = 1.milliseconds
      ..syncIntervalWhenConnected = 1.milliseconds;
  });
  tearDown(() {
    interval.stop();
  });

  test('should not producing event if not started', () async {
    when(mqtt.isConnected).thenReturn(false);
    fakeAsync((a) {
      var buffer = <int>[];
      interval
          .interval()
          .map((it) => buffer.length + 1)
          .listen(expectAsync1((it) {
            buffer.add(it);
          }, count: 0));

      a.elapse(10.s);
      expect(buffer.length, 0);
    });
  });

  test('producing the correct amount', () async {
    when(mqtt.isConnected).thenReturn(true);
    interval.start();

    var stream = Stream.periodic(5.s, (it) => 5.s);
    fakeAsync((a) {
      var count = 1;
      interval.interval(stream).take(2).listen(expectAsync1((_) {
            expect(a.elapsed.inSeconds, 5 * count++);
          }, count: 2));

      a.elapse(10.s);
    });
  });

  test('should not producing event after stopped', () {
    when(mqtt.isConnected).thenReturn(true);
    var stream = Stream.periodic(1.s, (_) => 1.s);
    interval.start();

    fakeAsync((a) {
      var count = 0;
      interval.interval(stream).listen((it) {
        count += 1;
      });

      a.elapse(1.s);
      expect(count, 1);
      a.elapse(5.s);
      expect(count, 6);
      interval.stop();
      a.elapse(10.s);
      expect(count, 6);
    });
  });
}
