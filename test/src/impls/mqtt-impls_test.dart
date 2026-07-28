import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:qiscus_chat_sdk/src/impls/mqtt-impls.dart';
import 'package:test/test.dart';

/// Waktu tunggu yang cukup untuk timer attach 300ms di `mqttUpdate2`.
const _afterAttach = Duration(milliseconds: 500);

/// `MqttClient` yang `updates`-nya bisa kita ganti-ganti instance-nya, meniru
/// dependensi realtime yang membangun ulang notifier-nya setiap koneksi
/// dibangun ulang.
class FakeMqttClient extends MqttClient {
  FakeMqttClient() : super('localhost', 'test-client');

  StreamController<MqttUpdatesData>? _controller;

  @override
  Stream<MqttUpdatesData>? get updates => _controller?.stream;

  void openUpdates() {
    // `sync: true` meniru stream notifier milik dependensi realtime.
    _controller = StreamController<MqttUpdatesData>.broadcast(sync: true);
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

    // `onAutoReconnected` wajib terpasang supaya listener tetap tersambung
    // kalau sebuah versi dependensi membangun ulang stream update-nya saat auto
    // reconnect. Versi sekarang tidak menggantinya, jadi ini jaring pengaman
    // - lihat komentar di `mqttUpdate2`.
    expect(mqtt.onAutoReconnected, isNotNull);

    // Koneksi pertama.
    mqtt.openUpdates();
    mqtt.onConnected!();
    await Future<void>.delayed(_afterAttach);
    mqtt.publish('before-reconnect');
    await Future<void>.delayed(Duration.zero);
    expect(received, ['before-reconnect']);

    // Auto reconnect: stream `updates` yang lama selesai, lalu dependensi
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
    // stream internal selesai - tidak ada reconnect yang bisa
    // menghidupkannya lagi, app harus restart.
    await mqtt.closeUpdates();
    await Future<void>.delayed(_afterAttach);

    expect(closed, isFalse);
  });

  // Ini kasus NYATA pada versi dependensi sekarang: auto reconnect TIDAK
  // membangun ulang notifier-nya, jadi `mqtt.updates` mengembalikan instance
  // yang persis sama. Karena listener dipasang dari dua callback
  // (`onConnected` dan `onAutoReconnected`), pertanyaannya adalah apakah
  // keduanya bisa menumpuk jadi dua subscription ke stream yang sama.
  test('mqttUpdate2 delivers once when attach runs twice on the same stream',
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

    // Auto reconnect tanpa mengganti instance `updates`.
    mqtt.onAutoReconnected!();
    await Future<void>.delayed(_afterAttach);

    mqtt.publish('only-once');
    await Future<void>.delayed(Duration.zero);

    expect(received, ['only-once']);
  });

  test('mqttUpdate2 delivers once when attach is interrupted mid-poll',
      () async {
    var mqtt = FakeMqttClient();
    var received = <String>[];

    var subs = mqttUpdate2(mqtt).listen((data) {
      received.addAll(data.map((it) => it.topic));
    });
    addTearDown(subs.cancel);

    // Kedua callback dipanggil beruntun SEBELUM timer attach 300ms sempat
    // berjalan, jadi ada dua timer yang berlomba.
    mqtt.openUpdates();
    mqtt.onConnected!();
    mqtt.onAutoReconnected!();
    mqtt.onConnected!();
    await Future<void>.delayed(_afterAttach);

    mqtt.publish('only-once');
    await Future<void>.delayed(Duration.zero);

    expect(received, ['only-once']);
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
