// Read actual dependency callback snapshots; never mutate its handler.
// ignore_for_file: invalid_use_of_protected_member
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';
import 'package:test/test.dart';

import 'support/mqtt_broker.dart';

class LazyObservedSDK extends QiscusSDK {
  final applicationStreamsBuilt = <String>[];

  @override
  Stream<QMessage> getMessageReceivedStream({
    required StreamController<QMessage> messageReceivedSubs$,
    required Future<void> Function(
            {required int roomId, required int messageId})
        markAsDelivered,
    required Future<T> Function<T>(QInterceptor, T) triggerHook,
  }) {
    applicationStreamsBuilt.add('received');
    return super.getMessageReceivedStream(
        messageReceivedSubs$: messageReceivedSubs$,
        markAsDelivered: markAsDelivered,
        triggerHook: triggerHook);
  }

  @override
  Stream<QMessage> getMessageReadStream() {
    applicationStreamsBuilt.add('read');
    return super.getMessageReadStream();
  }

  @override
  Stream<QMessage> getMessageDeliveredStream() {
    applicationStreamsBuilt.add('delivered');
    return super.getMessageDeliveredStream();
  }

  @override
  Stream<QMessage> getMessageDeletedStream() {
    applicationStreamsBuilt.add('deleted');
    return super.getMessageDeletedStream();
  }

  @override
  Stream<QMessage> getMessageUpdatedStream() {
    applicationStreamsBuilt.add('updated');
    return super.getMessageUpdatedStream();
  }

  @override
  Stream<QUserTyping> getUserTypingStream() {
    applicationStreamsBuilt.add('typing');
    return super.getUserTypingStream();
  }

  @override
  Stream<QUserPresence> getUserPresenceStream() {
    applicationStreamsBuilt.add('presence');
    return super.getUserPresenceStream();
  }

  @override
  Stream<int> getRoomClearedStream() {
    applicationStreamsBuilt.add('cleared');
    return super.getRoomClearedStream();
  }
}

class SdkFixture {
  SdkFixture(this.broker) {
    sdk.storage
      ..appId = 'loopback-test'
      ..brokerUrl = '127.0.0.1'
      ..isSyncEnabled = false;
    final mqtt = sdk.mqtt as MqttServerClient;
    mqtt
      ..secure = false
      ..port = broker.port
      ..keepAlivePeriod = 0;
    sdk.dio.interceptors.add(InterceptorsWrapper(onRequest: (request, handler) {
      final login = request.path == 'login_or_register' ||
          request.path == 'auth/verify_identity_token';
      if (!login && request.path != 'update_comment_status') {
        handler.reject(DioException(
            requestOptions: request, error: 'Unexpected HTTP in MQTT test'));
        return;
      }
      handler.resolve(Response<Map<String, Object?>>(
          requestOptions: request,
          statusCode: 200,
          data: login
              ? {
                  'results': {
                    'user': {
                      'email': 'listener-id',
                      'username': 'listener-name',
                      'avatar_url': 'https://example.com/avatar.png',
                      'last_comment_id': 0,
                      'last_sync_event_id': 0,
                      'extras': '{}',
                      'token': 'loopback-token',
                    }
                  }
                }
              : {'results': {}}));
    }));
  }

  final TestMqttBroker broker;
  final sdk = LazyObservedSDK();
  final subscriptions = <StreamSubscription<dynamic>>[];
  bool consumerClosed = false;

  List<int> listen() {
    final ids = <int>[];
    subscriptions.add(sdk.onMessageReceived().listen(
        (message) => ids.add(message.id),
        onDone: () => consumerClosed = true));
    return ids;
  }

  Future<void> send(int id, List<int> ids, List<int> expected) async {
    await broker.publish('loopback-token/c', mqttComment(id));
    await waitFor(() => ids.contains(id));
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(ids, expected);
    expect(consumerClosed, isFalse);
  }

  Future<void> login() async {
    await sdk.setUser(userId: 'listener-id', userKey: 'test-key');
    await ready();
  }

  Future<void> ready() async {
    await waitFor(() =>
        sdk.mqtt.connectionStatus?.state == MqttConnectionState.connected &&
        sdk.mqtt.getSubscriptionsStatus('loopback-token/c') ==
            MqttSubscriptionStatus.active);
  }

  void expectSnapshots() {
    expect(sdk.mqtt.connectionHandler!.onConnected, isNotNull,
        reason: 'Bridge must exist before mqtt_client snapshots callbacks');
    expect(sdk.mqtt.connectionHandler!.onAutoReconnected, isNotNull);
    expect(
        identical(
            sdk.mqtt.onConnected, sdk.mqtt.connectionHandler!.onConnected),
        isTrue);
    expect(
        identical(sdk.mqtt.onAutoReconnected,
            sdk.mqtt.connectionHandler!.onAutoReconnected),
        isTrue);
  }

  Future<void> close() async {
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
    sdk.mqtt.autoReconnect = false;
    await sdk.clearUser();
    sdk.dio.close(force: true);
    await sdk.realtimeErrors$.close();
    await broker.close();
  }
}

void main() {
  test('first manual open snapshots bridge without an application listener',
      () async {
    final fixture = SdkFixture(await TestMqttBroker.start());
    addTearDown(fixture.close);
    fixture.sdk.storage.isRealtimeEnabled = false;
    await fixture.sdk.setUser(userId: 'listener-id', userKey: 'test-key');
    expect(fixture.broker.connections, 0);
    fixture.sdk.storage.isRealtimeEnabled = true;
    expect(await fixture.sdk.openRealtimeConnection(), isTrue);
    fixture.expectSnapshots();
    expect(fixture.sdk.applicationStreamsBuilt, isEmpty);

    // Hard open does not promise to restore topic subscriptions. Subscribe at
    // the public transport seam to isolate bridge delivery from that contract.
    fixture.sdk.mqtt.subscribe('loopback-token/c', MqttQos.atLeastOnce);
    await fixture.ready();
    final ids = <int>[];
    fixture.subscriptions.add(fixture.sdk
        .onMessageReceived()
        .listen((message) => ids.add(message.id)));
    await fixture.broker.publish('loopback-token/c', mqttComment(1));
    await waitFor(() => ids.isNotEmpty);
    expect(ids, [1]);
  });

  test('setUser snapshots bridge before the first late application listener',
      () async {
    final fixture = SdkFixture(await TestMqttBroker.start());
    addTearDown(fixture.close);
    await fixture.login();

    // FIRST application-stream access is still later than connect/SUBACK.
    fixture.expectSnapshots();
    expect(fixture.sdk.applicationStreamsBuilt, isEmpty);
    final ids = <int>[];
    fixture.subscriptions.add(fixture.sdk
        .onMessageReceived()
        .listen((message) => ids.add(message.id)));
    await fixture.broker.publish('loopback-token/c', mqttComment(1));
    await waitFor(() => ids.isNotEmpty);
    expect(ids, [1]);
  });

  test(
      'early application listener receives through the actual connect callback',
      () async {
    final fixture = SdkFixture(await TestMqttBroker.start());
    addTearDown(fixture.close);
    final ids = fixture.listen();
    await fixture.login();
    fixture.expectSnapshots();
    await fixture.send(1, ids, [1]);
  });

  test('identity-token login snapshots bridge before late stream access',
      () async {
    final fixture = SdkFixture(await TestMqttBroker.start());
    addTearDown(fixture.close);
    await fixture.sdk.setUserWithIdentityToken(token: 'test-identity-token');
    await fixture.ready();
    fixture.expectSnapshots();
    expect(fixture.sdk.applicationStreamsBuilt, isEmpty);
    final ids = fixture.listen();
    await fixture.send(1, ids, [1]);
  });

  test('actual auto reconnect keeps multiple late consumers delivering once',
      () async {
    final fixture = SdkFixture(await TestMqttBroker.start());
    addTearDown(fixture.close);
    await fixture.login();
    final first = fixture.listen(), second = fixture.listen();
    await fixture.send(1, first, [1]);
    expect(second, [1]);
    final manager = fixture.sdk.mqtt.subscriptionsManager;
    fixture.sdk.mqtt.doAutoReconnect(force: true);
    await waitFor(() => fixture.broker.connections == 2);
    await fixture.ready();
    await waitFor(
        () => !fixture.sdk.mqtt.connectionHandler!.autoReconnectInProgress);
    fixture.expectSnapshots();
    expect(identical(manager, fixture.sdk.mqtt.subscriptionsManager), isTrue);
    await fixture.send(2, first, [1, 2]);
    expect(second, [1, 2]);
    await fixture.subscriptions.first.cancel();
    await fixture.send(3, second, [1, 2, 3]);
    expect(first, [1, 2]);
    expect(fixture.sdk.applicationStreamsBuilt, ['received']);
  });

  test('hard close and open rebinds existing consumer to a new update manager',
      () async {
    final fixture = SdkFixture(await TestMqttBroker.start());
    addTearDown(fixture.close);
    await fixture.login();
    final ids = fixture.listen();
    await fixture.send(1, ids, [1]);
    final manager = fixture.sdk.mqtt.subscriptionsManager;
    expect(await fixture.sdk.closeRealtimeConnection(), isTrue);
    expect(fixture.sdk.mqtt.subscriptionsManager, isNull);
    expect(fixture.sdk.mqtt.connectionHandler, isNull);
    expect(fixture.consumerClosed, isFalse);
    expect(await fixture.sdk.openRealtimeConnection(), isTrue);
    fixture.expectSnapshots();
    expect(identical(manager, fixture.sdk.mqtt.subscriptionsManager), isFalse);
    // Preserve existing hard-open topic semantics (not part of this fix).
    fixture.sdk.mqtt.subscribe('loopback-token/c', MqttQos.atLeastOnce);
    await fixture.ready();
    await fixture.send(2, ids, [1, 2]);
  });

  test('clearUser then login reuses SDK and its existing consumer stream',
      () async {
    final fixture = SdkFixture(await TestMqttBroker.start());
    addTearDown(fixture.close);
    await fixture.login();
    final ids = fixture.listen();
    await fixture.send(1, ids, [1]);
    final manager = fixture.sdk.mqtt.subscriptionsManager;
    await fixture.sdk.clearUser();
    expect(fixture.sdk.isLogin, isFalse);
    expect(fixture.sdk.mqtt.connectionStatus!.state,
        MqttConnectionState.disconnected);
    expect(fixture.sdk.mqtt.subscriptionsManager, isNull);
    expect(fixture.sdk.mqtt.connectionHandler, isNull);
    await waitFor(() => fixture.broker.peers.isEmpty);
    expect(fixture.consumerClosed, isFalse);
    await fixture.login();
    fixture.expectSnapshots();
    expect(identical(manager, fixture.sdk.mqtt.subscriptionsManager), isFalse);
    await fixture.send(2, ids, [1, 2]);
    expect(fixture.sdk.applicationStreamsBuilt, ['received']);
  });
}
