import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:qiscus_chat_sdk/src/impls/mqtt-impls.dart';
import 'package:test/test.dart';

/// Waktu tunggu yang cukup untuk timer attach 300ms di `mqttUpdate2`.
const _afterAttach = Duration(milliseconds: 500);

/// `MqttClient` yang `updates`-nya bisa kita ganti-ganti instance-nya, meniru
/// `mqtt_client` yang membangun ulang subscription notifier setiap koneksi
/// dibangun ulang.
class FakeMqttClient extends MqttClient {
  FakeMqttClient() : super('localhost', 'test-client');

  StreamController<MqttUpdatesData>? _controller;

  @override
  Stream<MqttUpdatesData>? get updates => _controller?.stream;

  void openUpdates() {
    _controller = StreamController<MqttUpdatesData>.broadcast();
  }

  Future<void> closeUpdates() async {
    await _controller?.close();
    _controller = null;
  }

  void publish(String topic) {
    _controller?.add([MqttReceivedMessage(topic, MqttPublishMessage())]);
  }
}

void main() {
  test('mqttUpdate2 attaches on the auto reconnect path', () async {
    var mqtt = FakeMqttClient();
    var received = <String>[];

    var subs = mqttUpdate2(mqtt).listen((data) {
      received.addAll(data.map((it) => it.topic));
    });
    addTearDown(subs.cancel);

    // `onAutoReconnected` wajib terpasang. Kalau hanya `onConnected` yang
    // dipasang, listener internal tidak pernah tersambung ulang setelah auto
    // reconnect - itulah "zombie connection" yang dilaporkan Klikdokter.
    expect(mqtt.onAutoReconnected, isNotNull);

    // Koneksi pertama.
    mqtt.openUpdates();
    mqtt.onConnected!();
    await Future<void>.delayed(_afterAttach);
    mqtt.publish('before-reconnect');
    await Future<void>.delayed(Duration.zero);
    expect(received, ['before-reconnect']);

    // Auto reconnect: stream `updates` yang lama selesai, lalu `mqtt_client`
    // memanggil `onAutoReconnected` - BUKAN `onConnected`.
    await mqtt.closeUpdates();
    mqtt.openUpdates();
    mqtt.onAutoReconnected!();
    await Future<void>.delayed(_afterAttach);
    mqtt.publish('after-reconnect');
    await Future<void>.delayed(Duration.zero);

    expect(received, ['before-reconnect', 'after-reconnect']);
  });

  test('mqttUpdate2 keeps the consumer stream open when updates completes',
      () async {
    var mqtt = FakeMqttClient();
    var closed = false;

    var subs = mqttUpdate2(mqtt).listen((_) {}, onDone: () => closed = true);
    addTearDown(subs.cancel);

    mqtt.openUpdates();
    mqtt.onConnected!();
    await Future<void>.delayed(_afterAttach);

    // Sebelumnya `onDone` memanggil `closeSync()` pada controller consumer,
    // sehingga `onMessageReceived()` milik aplikasi tertutup PERMANEN begitu
    // stream MQTT internal selesai - tidak ada reconnect yang bisa
    // menghidupkannya lagi, app harus restart.
    await mqtt.closeUpdates();
    await Future<void>.delayed(_afterAttach);

    expect(closed, isFalse);
  });

  test('mqttUpdate2 stops forwarding after an intentional disconnect',
      () async {
    var mqtt = FakeMqttClient();
    var received = <String>[];

    var subs = mqttUpdate2(mqtt).listen((data) {
      received.addAll(data.map((it) => it.topic));
    });
    addTearDown(subs.cancel);

    mqtt.openUpdates();
    mqtt.onConnected!();
    await Future<void>.delayed(_afterAttach);

    mqtt.onDisconnected!();
    await Future<void>.delayed(Duration.zero);
    mqtt.publish('after-disconnect');
    await Future<void>.delayed(Duration.zero);

    expect(received, isEmpty);
  });
}
