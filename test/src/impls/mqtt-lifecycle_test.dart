import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:qiscus_chat_sdk/src/impls/mqtt-impls.dart';
import 'package:test/test.dart';

class ControlledMqttClient extends MqttClient {
  ControlledMqttClient() : super('localhost', 'lifecycle-test');

  final source = StreamController<MqttUpdatesData>.broadcast(sync: true);
  final status = MqttClientConnectionStatus();
  bool available = true;
  int activeSubscriptions = 0;
  int peakSubscriptions = 0;
  late final tracked = Stream<MqttUpdatesData>.multi((controller) {
    activeSubscriptions++;
    if (activeSubscriptions > peakSubscriptions) {
      peakSubscriptions = activeSubscriptions;
    }
    final subscription = source.stream.listen(controller.addSync,
        onError: controller.addErrorSync, onDone: controller.closeSync);
    controller.onCancel = () {
      activeSubscriptions--;
      subscription.cancel();
    };
  }, isBroadcast: true);

  @override
  MqttClientConnectionStatus get connectionStatus => status;

  @override
  Stream<MqttUpdatesData>? get updates => available ? tracked : null;

  void publish(String topic) =>
      source.add([MqttReceivedMessage(topic, MqttPublishMessage())]);
}

void main() {
  test('adapter creates no polling timers without an available connection', () {
    fakeAsync((async) {
      final mqtt = ControlledMqttClient()..available = false;
      mqtt.status.state = MqttConnectionState.disconnected;
      final stream = mqttUpdate2(mqtt);
      final subscription = stream.listen((_) {});
      // Includes callbacks fired without a source, never connected and logout.
      mqtt.onConnected!();
      mqtt.onAutoReconnected!();
      async.elapse(const Duration(minutes: 1));
      expect(async.periodicTimerCount, 0);
      expect(async.nonPeriodicTimerCount, 0);
      expect(mqtt.activeSubscriptions, 0);
      mqtt.available = true;
      mqtt.status.state = MqttConnectionState.connected;
      mqtt.onConnected!();
      expect(mqtt.activeSubscriptions, 1);
      expect(async.pendingTimers, isEmpty);
      mqtt.status.state = MqttConnectionState.disconnected;
      mqtt.onDisconnected!();
      subscription.cancel();
      mqtt.source.close();
      async.flushMicrotasks();
      expect(async.pendingTimers, isEmpty);
      expect(mqtt.activeSubscriptions, 0);
    });
  });

  test(
      'multiple consumers share one source across repeated connection callbacks',
      () async {
    final mqtt = ControlledMqttClient();
    mqtt.status.state = MqttConnectionState.connected;
    final stream = mqttUpdate2(mqtt);
    final firstIds = <String>[], secondIds = <String>[];
    final first = stream.listen(
        (events) => firstIds.addAll(events.map((event) => event.topic)));
    final second = stream.listen(
        (events) => secondIds.addAll(events.map((event) => event.topic)));
    addTearDown(() async {
      await first.cancel();
      await second.cancel();
      mqtt.onDisconnected?.call();
      await mqtt.source.close();
    });
    expect(mqtt.activeSubscriptions, 1);
    for (var i = 0; i < 5; i++) {
      mqtt.onConnected!();
      mqtt.onAutoReconnected!();
    }
    mqtt.publish('once');
    await Future<void>.delayed(Duration.zero);
    expect(firstIds, ['once']);
    expect(secondIds, ['once']);
    expect(mqtt.activeSubscriptions, 1);
    expect(mqtt.peakSubscriptions, 1);
    await first.cancel();
    expect(mqtt.activeSubscriptions, 1);
    mqtt.publish('second-only');
    await Future<void>.delayed(Duration.zero);
    expect(firstIds, ['once']);
    expect(secondIds, ['once', 'second-only']);
    await second.cancel();
    expect(mqtt.activeSubscriptions, 0);
    mqtt.onAutoReconnected!();
    expect(mqtt.activeSubscriptions, 0);
  });

  test('disconnect detaches immediately while keeping consumers for reconnect',
      () async {
    final mqtt = ControlledMqttClient();
    mqtt.status.state = MqttConnectionState.connected;
    var done = false;
    final received = <String>[];
    final subscription = mqttUpdate2(mqtt).listen(
        (events) => received.addAll(events.map((event) => event.topic)),
        onDone: () => done = true);
    addTearDown(() async {
      await subscription.cancel();
      mqtt.onDisconnected?.call();
      await mqtt.source.close();
    });
    mqtt.status.state = MqttConnectionState.disconnected;
    mqtt.onDisconnected!();
    expect(mqtt.activeSubscriptions, 0);
    mqtt.publish('discarded');
    mqtt.status.state = MqttConnectionState.connected;
    mqtt.onConnected!();
    mqtt.publish('reconnected');
    await Future<void>.delayed(Duration.zero);
    expect(done, isFalse);
    expect(received, ['reconnected']);
    expect(mqtt.peakSubscriptions, 1);
  });

  test(
      'last consumer cancellation releases source and a new consumer reattaches',
      () async {
    final mqtt = ControlledMqttClient();
    mqtt.status.state = MqttConnectionState.connected;
    final stream = mqttUpdate2(mqtt);
    final first = stream.listen((_) {});
    StreamSubscription<MqttUpdatesData>? second;
    addTearDown(() async {
      await first.cancel();
      await second?.cancel();
      mqtt.onDisconnected?.call();
      await mqtt.source.close();
    });
    expect(mqtt.source.hasListener, isTrue);
    await first.cancel();
    expect(mqtt.source.hasListener, isFalse);

    final received = <String>[];
    second = stream.listen((batch) {
      received.addAll(batch.map((event) => event.topic));
    });
    mqtt.publish('resumed');
    await Future<void>.delayed(Duration.zero);
    expect(received, ['resumed']);
    await second.cancel();
    expect(mqtt.source.hasListener, isFalse);
  });

  test('late adapter attaches to an already connected source without callbacks',
      () async {
    final mqtt = ControlledMqttClient();
    mqtt.status.state = MqttConnectionState.connected;
    final received = <String>[];
    final subscription = mqttUpdate2(mqtt).listen((batch) {
      received.addAll(batch.map((event) => event.topic));
    });
    addTearDown(() async {
      await subscription.cancel();
      mqtt.onDisconnected?.call();
      await mqtt.source.close();
    });

    // No connect/reconnect callback is fired after the late adapter is created.
    mqtt.publish('late');
    await Future<void>.delayed(Duration.zero);
    expect(received, ['late']);
  });
}
