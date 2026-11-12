// Menguji sinkronisasi saat aplikasi kembali ke foreground (resume).
//
// Memakai `WidgetsFlutterBinding` asli, bukan `flutter_test`: `flutter_test`
// mem-pin versi `matcher`/`test_api` yang bentrok dengan dev dependency
// `test` milik paket ini. Binding di-inisialisasi oleh TEST, bukan oleh SDK.
// ignore_for_file: invalid_use_of_protected_member
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart'
    show AppLifecycleState, WidgetsBinding, WidgetsFlutterBinding;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';
import 'package:qiscus_chat_sdk/src/app_lifecycle.dart';
import 'package:test/test.dart';

import 'support/mqtt_broker.dart';

const _token = 'resume-token';

class ResumeFixture {
  ResumeFixture({this.broker}) {
    sdk.storage
      ..appId = 'resume-test'
      ..brokerUrl = '127.0.0.1'
      ..isRealtimeEnabled = broker != null
      ..isSyncEnabled = true
      ..isSyncEventEnabled = true;
    final mqtt = sdk.mqtt as MqttServerClient;
    mqtt
      ..secure = false
      ..port = broker?.port ?? 0
      ..keepAlivePeriod = 0;
    sdk.dio.interceptors.add(InterceptorsWrapper(onRequest: (request, handler) {
      // Interceptor SDK sudah memindahkan query parameter ke `path`.
      final uri = Uri.parse(request.path);
      requests.add(uri);
      if (failSync && uri.path.startsWith('sync')) {
        handler.reject(DioException(requestOptions: request, error: 'offline'));
        return;
      }
      Object data;
      switch (uri.path) {
        case 'login_or_register':
          data = {
            'results': {
              'user': {
                'email': 'resume-user',
                'username': 'resume-user',
                'avatar_url': 'https://example.com/avatar.png',
                'last_comment_id': 10,
                'last_sync_event_id': 20,
                'extras': '{}',
                'token': _token,
              }
            }
          };
          break;
        case 'sync':
          data = {
            'results': {
              'meta': {'last_received_comment_id': 10},
              'comments': <Object>[],
            }
          };
          break;
        case 'sync_event':
          data = {'events': <Object>[]};
          break;
        default:
          handler.reject(DioException(
              requestOptions: request, error: 'Unexpected HTTP in test'));
          return;
      }
      handler.resolve(Response<Object>(
          requestOptions: request, statusCode: 200, data: data));
    }));
  }

  final TestMqttBroker? broker;
  final sdk = QiscusSDK();
  final requests = <Uri>[];
  bool failSync = false;

  List<Uri> path(String p) => requests.where((r) => r.path == p).toList();

  Future<void> login() =>
      sdk.setUser(userId: 'resume-user', userKey: 'resume-key');

  Future<void> close() async {
    sdk.mqtt.autoReconnect = false;
    await sdk.clearUser();
    sdk.dio.close(force: true);
    await broker?.close();
  }
}

/// Simulasi aplikasi masuk background lalu kembali ke foreground, lewat jalur
/// yang sama dengan engine (`handleAppLifecycleStateChanged`).
void backgroundThenResume() {
  final binding = WidgetsBinding.instance;
  binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
  binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
}

/// Tunggu sebentar supaya request async (kalau ada) sempat lewat interceptor.
Future<void> settle() =>
    Future<void>.delayed(const Duration(milliseconds: 200));

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  test('resume while logged in syncs messages and events immediately',
      () async {
    final f = ResumeFixture();
    addTearDown(f.close);
    await f.login();
    await settle();
    expect(f.path('sync'), isEmpty);
    expect(f.path('sync_event'), isEmpty);

    backgroundThenResume();
    await waitFor(
        () => f.path('sync').isNotEmpty && f.path('sync_event').isNotEmpty);
    await settle();

    expect(f.path('sync'), hasLength(1));
    expect(f.path('sync_event'), hasLength(1));
    // Memakai cursor yang sedang berlaku, bukan mulai dari 0.
    expect(f.path('sync').single.queryParameters['last_received_comment_id'],
        '10');
    expect(f.path('sync_event').single.queryParameters['start_event_id'], '20');
  });

  test('failed sync on resume is reported, not thrown', () async {
    final f = ResumeFixture();
    addTearDown(f.close);
    await f.login();
    final errors = <QError>[];
    final sub = f.sdk.onRealtimeError().listen(errors.add);
    addTearDown(sub.cancel);
    f.failSync = true;

    backgroundThenResume();
    // Error yang lolos ke zone test akan menggagalkan test ini.
    await waitFor(() => errors.length >= 2);
    expect(f.path('sync'), hasLength(1));
    expect(f.path('sync_event'), hasLength(1));
  });

  test('rapid resumes are debounced into one sync', () async {
    final f = ResumeFixture();
    addTearDown(f.close);
    await f.login();

    backgroundThenResume();
    backgroundThenResume();
    f.sdk.handleAppResumed();
    await waitFor(() => f.path('sync').isNotEmpty);
    await settle();

    expect(f.path('sync'), hasLength(1));
    expect(f.path('sync_event'), hasLength(1));
  });

  test('no request on resume when logged out or after clearUser', () async {
    final f = ResumeFixture();
    addTearDown(f.close);

    backgroundThenResume();
    f.sdk.handleAppResumed();
    await settle();
    expect(f.requests, isEmpty);

    await f.login();
    final account = f.sdk.currentUser;
    await f.sdk.clearUser();
    backgroundThenResume();
    f.sdk.handleAppResumed();
    await settle();
    expect(f.path('sync'), isEmpty);
    expect(f.path('sync_event'), isEmpty);

    // Observer harus benar-benar dilepas oleh clearUser, bukan sekadar
    // tertahan cek login: kembalikan state login TANPA setUser, lalu resume.
    f.sdk.storage
      ..currentUser = account
      ..token = _token;
    backgroundThenResume();
    await settle();
    expect(f.path('sync'), isEmpty);
    await f.sdk.clearUser();

    // Login ulang tidak mendaftarkan observer dua kali, dan debounce dari
    // sesi sebelumnya tidak terbawa.
    await f.login();
    await f.login();
    backgroundThenResume();
    await waitFor(() => f.path('sync').isNotEmpty);
    await settle();
    expect(f.path('sync'), hasLength(1));
  });

  test('enableAutoSyncOnResume(enable: false) disables the automatic path',
      () async {
    final f = ResumeFixture();
    addTearDown(f.close);
    f.sdk.enableAutoSyncOnResume(enable: false);
    expect(f.sdk.isAutoSyncOnResumeEnabled, isFalse);
    await f.login();

    backgroundThenResume();
    await settle();
    expect(f.path('sync'), isEmpty);
    expect(f.path('sync_event'), isEmpty);

    // Jalur manual tetap jalan untuk aplikasi yang memasang observer sendiri.
    f.sdk.handleAppResumed();
    await waitFor(() => f.path('sync').isNotEmpty);
    expect(f.path('sync'), hasLength(1));
  });

  test('re-enabling auto sync while logged in registers the observer again',
      () async {
    final f = ResumeFixture();
    addTearDown(f.close);
    await f.login();
    f.sdk.enableAutoSyncOnResume(enable: false);
    f.sdk.enableAutoSyncOnResume(enable: true);
    expect(f.sdk.isAutoSyncOnResumeEnabled, isTrue);

    backgroundThenResume();
    await waitFor(() => f.path('sync').isNotEmpty);
    await settle();
    expect(f.path('sync'), hasLength(1));
  });

  test('sync flags from app config are honoured on resume', () async {
    final f = ResumeFixture();
    addTearDown(f.close);
    f.sdk.storage
      ..isSyncEnabled = true
      ..isSyncEventEnabled = false;
    await f.login();

    backgroundThenResume();
    await waitFor(() => f.path('sync').isNotEmpty);
    await settle();
    expect(f.path('sync'), hasLength(1));
    expect(f.path('sync_event'), isEmpty);
  });

  group('realtime', () {
    test('resume reconnects MQTT when the initial connect failed', () async {
      // Port yang tidak ada listener-nya: connect awal gagal, dan mqtt_client
      // TIDAK pernah auto reconnect bila koneksi pertama belum pernah sukses.
      final dead = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final deadPort = dead.port;
      await dead.close();

      final f = ResumeFixture(broker: await TestMqttBroker.start());
      addTearDown(f.close);
      (f.sdk.mqtt as MqttServerClient).port = deadPort;
      await f.login();
      await waitFor(() =>
          f.sdk.mqtt.connectionStatus?.state == MqttConnectionState.faulted);
      expect(f.broker!.connections, 0);

      (f.sdk.mqtt as MqttServerClient).port = f.broker!.port;
      backgroundThenResume();

      await waitFor(() =>
          f.sdk.mqtt.connectionStatus?.state == MqttConnectionState.connected &&
          f.sdk.mqtt.getSubscriptionsStatus('$_token/c') ==
              MqttSubscriptionStatus.active);
      expect(f.broker!.connections, 1);
    });

    test('resume does not reconnect a connected client', () async {
      final f = ResumeFixture(broker: await TestMqttBroker.start());
      addTearDown(f.close);
      await f.login();
      await waitFor(() =>
          f.sdk.mqtt.getSubscriptionsStatus('$_token/c') ==
          MqttSubscriptionStatus.active);

      backgroundThenResume();
      await waitFor(() => f.path('sync').isNotEmpty);
      await settle();
      expect(f.broker!.connections, 1);
      expect(f.sdk.mqtt.connectionStatus?.state, MqttConnectionState.connected);
    });

    test('resume respects a manually closed realtime connection', () async {
      final f = ResumeFixture(broker: await TestMqttBroker.start());
      addTearDown(f.close);
      await f.login();
      await waitFor(() =>
          f.sdk.mqtt.connectionStatus?.state == MqttConnectionState.connected);
      expect(await f.sdk.closeRealtimeConnection(), isTrue);

      backgroundThenResume();
      await waitFor(() => f.path('sync').isNotEmpty);
      await settle();
      expect(f.broker!.connections, 1);
      expect(
          f.sdk.mqtt.connectionStatus?.state, MqttConnectionState.disconnected);
    });
  });

  group('AppResumeSync', () {
    test('fires again once the debounce window has passed', () {
      var now = DateTime(2026);
      var calls = 0;
      final resume = AppResumeSync(
        onResumed: () {
          calls++;
          return true;
        },
        now: () => now,
      );

      expect(resume.trigger(), isTrue);
      now = now.add(const Duration(milliseconds: 500));
      expect(resume.trigger(), isFalse);
      now = now.add(AppResumeSync.defaultDebounce);
      expect(resume.trigger(), isTrue);
      expect(calls, 2);
    });

    test('a skipped run does not start the debounce window', () {
      var ran = false;
      var calls = 0;
      final resume = AppResumeSync(onResumed: () {
        calls++;
        return ran;
      });

      expect(resume.trigger(), isFalse);
      ran = true;
      expect(resume.trigger(), isTrue);
      expect(calls, 2);
    });

    test('attach registers once and detach unregisters', () {
      final resume = AppResumeSync(onResumed: () => true);
      expect(resume.attach(), isTrue);
      expect(resume.attach(), isTrue);
      expect(resume.isAttached, isTrue);
      resume.detach();
      expect(resume.isAttached, isFalse);
      // Sudah tidak terdaftar: removeObserver mengembalikan false.
      expect(WidgetsBinding.instance.removeObserver(resume), isFalse);

      resume.attach();
      expect(WidgetsBinding.instance.removeObserver(resume), isTrue);
      expect(WidgetsBinding.instance.removeObserver(resume), isFalse);
    });

    test('only resumed triggers', () {
      var calls = 0;
      final resume = AppResumeSync(onResumed: () {
        calls++;
        return true;
      });
      for (final state in AppLifecycleState.values) {
        if (state != AppLifecycleState.resumed) {
          resume.didChangeAppLifecycleState(state);
        }
      }
      expect(calls, 0);
      resume.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(calls, 1);
    });
  });
}
