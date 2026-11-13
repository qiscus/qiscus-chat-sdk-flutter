import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/debug.dart';
import 'package:qiscus_chat_sdk/src/impls/mqtt-impls.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mqtt_sdk_lifecycle_test.dart' show SdkFixture;
import '../support/mqtt_broker.dart';

void main() {
  // Broker produksi menolak wildcard room dalam format apa pun, termasuk
  // `r/<room>/<room>/+/r`; topic per peserta adalah fallback-nya (lihat
  // room_topic_subscription_test.dart). Wildcard tetap format 2.2.7.
  test('receipt wildcard filters keep the 2.2.7 format; per-participant '
      'filters repeat the room ID', () {
    expect(TopicBuilder.messageRead('135852'), 'r/135852/+/+/r');
    expect(TopicBuilder.messageDelivered('135852'), 'r/135852/+/+/d');
    expect(TopicBuilder.messageReadBy('135852', 'a@b.c'), 'r/135852/135852/a@b.c/r');
    expect(TopicBuilder.messageDeliveredBy('135852', 'a@b.c'),
        'r/135852/135852/a@b.c/d');
  });

  test('disconnected subscribe returns local QError instead of success', () {
    final mqtt = MqttServerClient('127.0.0.1', 'local-test');
    final result = mqttSubscribeTopic('private-password/c').run(mqtt).run();
    expect(result.isLeft(), isTrue);
    result.match((error) {
      expect(error.message, contains('local'));
      expect(error.message, isNot(contains('private-password')));
    }, (_) => fail('must not succeed while disconnected'));
  });

  test('null local subscribe reports once without claiming broker rejection',
      () async {
    final broker = await TestMqttBroker.start();
    final fixture = SdkFixture(broker);
    final mqtt = fixture.sdk.mqtt;
    final errors = <QError>[];
    final errorSub = fixture.sdk.onRealtimeError().listen(errors.add);
    addTearDown(() async {
      await errorSub.cancel();
      mqtt.disconnect();
      await broker.close();
    });
    await mqtt.connect();
    fixture.sdk.subscribeUserOnlinePresence('private-password/#/invalid');
    await waitFor(() => errors.isNotEmpty);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(errors, hasLength(1));
    expect(errors.single.message, contains('local'));
    expect(errors.single.message, isNot(contains('broker')));
    expect(errors.single.message, isNot(contains('private-password')));
  });

  test('debug keeps existing callbacks and redacts token subscription events',
      () async {
    final mqtt = MqttServerClient('127.0.0.1', 'debug-test');
    final subscribed = <String>[];
    final unsubscribed = <String?>[];
    mqtt.onSubscribed = subscribed.add;
    mqtt.onUnsubscribed = unsubscribed.add;
    final debug = Debug(mqtt: mqtt, interval: const Stream<void>.empty());
    final debugSubscribed = <String>[];
    final debugUnsubscribed = <String>[];
    final sub = debug.onMqttSubscribed.listen(debugSubscribed.add);
    final unsub = debug.onMqttUnsubscribed.listen(debugUnsubscribed.add);
    addTearDown(() async {
      await sub.cancel();
      await unsub.cancel();
    });
    mqtt.onSubscribed!('secret-token/c');
    mqtt.onUnsubscribed!('secret-token/c');
    await Future<void>.delayed(Duration.zero);
    expect(subscribed, ['secret-token/c']);
    expect(unsubscribed, ['secret-token/c']);
    expect(debugSubscribed, ['[redacted]']);
    expect(debugUnsubscribed, ['[redacted]']);
  });

  test(
      'debug exposes sanitized failures without replacing existing failure callback',
      () async {
    final mqtt = MqttServerClient('127.0.0.1', 'debug-failure-test');
    final originalFailures = <String>[];
    mqtt.onSubscribeFail = originalFailures.add;
    final debug = Debug(mqtt: mqtt, interval: const Stream<void>.empty());
    final failures = <QError>[];
    final stream = debug.onMqttSubscribeFailed;
    final sub = stream.listen(failures.add);
    addTearDown(sub.cancel);
    mqtt.onSubscribeFail!('secret-password/c');
    await Future<void>.delayed(Duration.zero);
    expect(originalFailures, ['secret-password/c']);
    expect(failures, hasLength(1));
    expect(failures.single.message, contains('broker'));
    expect(failures.single.message, isNot(contains('secret-password')));
  });

  test('debug reports thrown local subscribe failure once without secrets',
      () async {
    final mqtt = MqttServerClient('127.0.0.1', 'debug-local-test');
    final debug = Debug(mqtt: mqtt, interval: const Stream<void>.empty());
    final failures = <QError>[];
    final sub = debug.onMqttSubscribeFailed.listen(failures.add);
    addTearDown(sub.cancel);
    expect(mqttSubscribeTopic('secret-password/c').run(mqtt).run().isLeft(),
        isTrue);
    await Future<void>.delayed(Duration.zero);
    expect(failures, hasLength(1));
    expect(failures.single.message, contains('local'));
    expect(failures.single.message, isNot(contains('secret-password')));
  });

  test('standalone wrapper never reports success for rejected SUBACK',
      () async {
    final broker = (await TestMqttBroker.start())..subscriptionGrant = 0x80;
    final mqtt = MqttServerClient('127.0.0.1', 'standalone-test')
      ..port = broker.port;
    final accepted = <String>[];
    mqtt.onSubscribed = accepted.add;
    addTearDown(() async {
      mqtt.disconnect();
      await broker.close();
    });
    await mqtt.connect();
    mqttSubscribeTopic(TopicBuilder.messageRead('135852')).run(mqtt).run();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(accepted, isEmpty);
  });

  for (final grant in [0, 1, 2, 0x80, -1]) {
    test(
        'real SUBACK grant $grant preserves callbacks and reports correct status',
        () async {
      final broker = (await TestMqttBroker.start())..subscriptionGrant = grant;
      final fixture = SdkFixture(broker);
      final mqtt = fixture.sdk.mqtt;
      final errors = <QError>[];
      final accepted = <String>[];
      final previousFailures = <String>[];
      final sdkFailureCallback = mqtt.onSubscribeFail;
      mqtt.onSubscribed = accepted.add;
      mqtt.onSubscribeFail = (topic) {
        previousFailures.add(topic);
        sdkFailureCallback?.call(topic);
      };
      final debug = Debug(mqtt: mqtt, interval: const Stream<void>.empty());
      final debugAccepted = <String>[];
      final debugFailures = <QError>[];
      final subs = [
        fixture.sdk.onRealtimeError().listen(errors.add),
        debug.onMqttSubscribed.listen(debugAccepted.add),
        debug.onMqttSubscribeFailed.listen(debugFailures.add),
      ];
      addTearDown(() async {
        for (final sub in subs) {
          await sub.cancel();
        }
        mqtt.disconnect();
        await broker.close();
      });
      await mqtt.connect();
      final topics = [
        TopicBuilder.messageRead('135852'),
        TopicBuilder.messageDelivered('135852')
      ];
      for (final topic in topics) {
        expect(mqttSubscribeTopic(topic).run(mqtt).run().isRight(), isTrue);
      }
      final rejected = grant == 0x80 || grant == -1;
      await waitFor(
          () => rejected ? debugFailures.length == 2 : accepted.length == 2);
      expect(accepted, rejected ? isEmpty : topics);
      expect(debugAccepted, rejected ? isEmpty : topics);
      expect(previousFailures, rejected ? topics : isEmpty);
      expect(errors, hasLength(rejected ? 2 : 0));
      expect(debugFailures, hasLength(rejected ? 2 : 0));
      for (final topic in topics) {
        expect(
            mqtt.getSubscriptionsStatus(topic),
            rejected
                ? MqttSubscriptionStatus.doesNotExist
                : MqttSubscriptionStatus.active);
      }
      if (rejected) {
        expect(errors.first.message, contains(topics.first));
        expect(debugFailures.first.message, contains(topics.first));
        expect(errors.first.message, contains('asynchronous'));
        expect(errors.first.message, contains('automatic re-subscribe'));
        expect(errors.first.message, contains('raw return code unavailable'));
      }
    });
  }

  test('failure observer survives reconnect without duplicated notifications',
      () async {
    final broker = await TestMqttBroker.start();
    final fixture = SdkFixture(broker);
    final mqtt = fixture.sdk.mqtt;
    final errors = <QError>[];
    final debug = Debug(mqtt: mqtt, interval: const Stream<void>.empty());
    final debugFailures = <QError>[];
    final subs = [
      fixture.sdk.onRealtimeError().listen(errors.add),
      debug.onMqttSubscribeFailed.listen(debugFailures.add)
    ];
    addTearDown(() async {
      for (final sub in subs) {
        await sub.cancel();
      }
      mqtt.disconnect();
      await broker.close();
    });
    await mqtt.connect();
    final topic = TopicBuilder.messageRead('135852');
    mqttSubscribeTopic(topic).run(mqtt).run();
    await waitFor(() =>
        mqtt.getSubscriptionsStatus(topic) == MqttSubscriptionStatus.active);
    mqtt.disconnect();
    await mqtt.connect();
    broker.subscriptionGrant = 0x80;
    mqttSubscribeTopic(topic).run(mqtt).run();
    await waitFor(() => errors.isNotEmpty);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(errors, hasLength(1));
    expect(debugFailures, hasLength(1));
    expect(mqtt.getSubscriptionsStatus(topic),
        MqttSubscriptionStatus.doesNotExist);
  });

  test('broker rejection emits sanitized realtime error and no success',
      () async {
    final broker = (await TestMqttBroker.start())..subscriptionGrant = 0x80;
    final fixture = SdkFixture(broker);
    final mqtt = fixture.sdk.mqtt;
    final errors = <QError>[];
    final accepted = <String>[];
    final errorSub = fixture.sdk.onRealtimeError().listen(errors.add);
    mqtt.onSubscribed = accepted.add;
    addTearDown(() async {
      await errorSub.cancel();
      mqtt.disconnect();
      await broker.close();
    });
    await mqtt.connect();
    const topic = 'secret-token/c';
    final result = mqttSubscribeTopic(topic).run(mqtt).run();
    expect(result.isRight(), isTrue,
        reason: 'local request queued, not confirmed');
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(mqtt.getSubscriptionsStatus(topic),
        MqttSubscriptionStatus.doesNotExist);
    expect(accepted, isEmpty, reason: 'failed SUBACK must not report success');
    expect(errors, hasLength(1));
    expect(errors.single.message, contains('broker'));
    expect(errors.single.message, isNot(contains('secret-token')));
    expect(errors.single.message, isNot(contains('128')),
        reason: 'callback has no raw numeric SUBACK code');
  });
}
