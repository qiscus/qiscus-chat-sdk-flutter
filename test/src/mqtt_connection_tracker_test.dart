// Menguji pelacakan status koneksi milik SDK yang menggantikan pembacaan
// field @protected mqtt_client saat resume.
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart' show WidgetsFlutterBinding;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';
import 'package:qiscus_chat_sdk/src/app_lifecycle.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/mqtt_broker.dart';

Future<void> until(bool Function() cond,
    {Duration timeout = const Duration(seconds: 10)}) async {
  final end = DateTime.now().add(timeout);
  while (!cond()) {
    if (DateTime.now().isAfter(end)) fail('condition not met in time');
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

MqttServerClient newClient(int port) => MqttServerClient('127.0.0.1', 'c$port')
  ..logging(on: false)
  ..port = port
  ..keepAlivePeriod = 0
  ..autoReconnect = true
  ..connectionMessage = MqttConnectMessage().withClientIdentifier('c$port');

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('MqttConnectionTracker', () {
    late TestMqttBroker broker;
    setUp(() async => broker = await TestMqttBroker.start());
    tearDown(() => broker.close());

    test('never connected -> hasConnected false, no auto reconnect', () {
      final tracker = MqttConnectionTracker(newClient(broker.port))..install();
      expect(tracker.hasConnected, isFalse);
      expect(tracker.autoReconnectInProgress, isFalse);
    });

    test('failed first connect is not "connected"', () async {
      final closed = await TestMqttBroker.start();
      final port = closed.port;
      await closed.close();
      final client = newClient(port);
      final tracker = MqttConnectionTracker(client)..install();
      try {
        await client.connect();
      } catch (_) {}
      expect(tracker.hasConnected, isFalse);
      expect(tracker.autoReconnectInProgress, isFalse);
      client.autoReconnect = false;
      client.disconnect();
    });

    test(
        'tracks connect, auto reconnect and deliberate disconnect, chaining '
        'existing callbacks', () async {
      final client = newClient(broker.port);
      final calls = <String>[];
      client
        ..onConnected = () {
          calls.add('connected');
        }
        ..onAutoReconnect = () {
          calls.add('autoReconnect');
        }
        ..onAutoReconnected = () {
          calls.add('autoReconnected');
        }
        ..onDisconnected = () {
          calls.add('disconnected');
        };
      final tracker = MqttConnectionTracker(client)
        ..install()
        ..install(); // idempoten: tidak membungkus dua kali

      await client.connect();
      expect(tracker.hasConnected, isTrue);
      expect(tracker.autoReconnectInProgress, isFalse);
      expect(calls, ['connected']);

      // Putus mendadak: mqtt_client auto reconnect ke broker yang sama.
      var sawInProgress = false;
      final poll = Timer.periodic(const Duration(milliseconds: 1), (_) {
        if (tracker.autoReconnectInProgress) sawInProgress = true;
      });
      for (final peer in broker.peers.toList()) {
        peer.socket.destroy();
      }
      await until(() => calls.contains('autoReconnected'));
      poll.cancel();
      expect(sawInProgress, isTrue);
      expect(tracker.hasConnected, isTrue);
      expect(tracker.autoReconnectInProgress, isFalse);
      expect(calls, containsAllInOrder(['autoReconnect', 'autoReconnected']));

      client.disconnect();
      expect(tracker.hasConnected, isFalse);
      expect(tracker.autoReconnectInProgress, isFalse);
      expect(calls.last, 'disconnected');
    });

    test('auto reconnect stays "in progress" while the broker is down',
        () async {
      final client = newClient(broker.port);
      final tracker = MqttConnectionTracker(client)..install();
      await client.connect();
      await broker.server.close();
      for (final peer in broker.peers.toList()) {
        peer.socket.destroy();
      }
      await until(() => tracker.autoReconnectInProgress);
      expect(tracker.hasConnected, isTrue);
      client.autoReconnect = false;
      client.disconnect();
      expect(tracker.autoReconnectInProgress, isFalse);
    });
  });

  group('resume reconnect decision', () {
    late TestMqttBroker broker;
    late QiscusSDK sdk;

    setUp(() async {
      broker = await TestMqttBroker.start();
      sdk = QiscusSDK();
      sdk.storage
        ..appId = 'tracker-test'
        ..brokerUrl = '127.0.0.1'
        ..isRealtimeEnabled = false
        ..isSyncEnabled = false
        ..isSyncEventEnabled = false;
      (sdk.mqtt as MqttServerClient)
        ..secure = false
        ..port = broker.port
        ..keepAlivePeriod = 0;
      sdk.dio.interceptors.add(InterceptorsWrapper(onRequest: (r, h) {
        h.resolve(Response<Object>(requestOptions: r, statusCode: 200, data: {
          'results': {
            'user': {
              'email': 'tracker-user',
              'username': 'tracker-user',
              'avatar_url': 'https://example.com/a.png',
              'last_comment_id': 1,
              'last_sync_event_id': 1,
              'extras': '{}',
              'token': 'tracker-token',
            }
          }
        }));
      }));
    });

    tearDown(() async {
      sdk.mqtt.autoReconnect = false;
      await sdk.clearUser();
      sdk.dio.close(force: true);
      await broker.close();
    });

    test('never connected -> resume runs the normal connect path', () async {
      await sdk.setUser(userId: 'tracker-user', userKey: 'k');
      expect(broker.connections, 0);

      sdk.storage.isRealtimeEnabled = true;
      sdk.handleAppResumed();
      await until(() =>
          sdk.mqtt.connectionStatus?.state == MqttConnectionState.connected);
      expect(broker.connections, 1);
    });

    test('connected -> resume does nothing to the connection', () async {
      sdk.storage.isRealtimeEnabled = true;
      await sdk.setUser(userId: 'tracker-user', userKey: 'k');
      await until(() =>
          sdk.mqtt.connectionStatus?.state == MqttConnectionState.connected);
      expect(broker.connections, 1);

      sdk.handleAppResumed();
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(broker.connections, 1);
      expect(sdk.mqtt.connectionStatus?.state, MqttConnectionState.connected);
    });

    test(
        'dropped after a good connect -> resume while auto reconnect runs '
        'opens no second connection', () async {
      sdk.storage.isRealtimeEnabled = true;
      await sdk.setUser(userId: 'tracker-user', userKey: 'k');
      await until(() =>
          sdk.mqtt.connectionStatus?.state == MqttConnectionState.connected);

      // Broker mati: auto reconnect terus mencoba dan tidak pernah sukses.
      await broker.server.close();
      for (final peer in broker.peers.toList()) {
        peer.socket.destroy();
      }
      await until(() =>
          sdk.mqtt.connectionStatus?.state != MqttConnectionState.connected);
      final before = broker.connections;

      // Broker hidup lagi di port yang sama; bila resume memulai connect
      // kedua, akan ada >1 koneksi baru untuk satu kali pemulihan.
      final revived = await TestMqttBroker.start(port: broker.port);
      addTearDown(revived.close);
      sdk.handleAppResumed();
      await until(() =>
          sdk.mqtt.connectionStatus?.state == MqttConnectionState.connected);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(before, 1);
      expect(revived.connections, 1);
    });
  });
}
