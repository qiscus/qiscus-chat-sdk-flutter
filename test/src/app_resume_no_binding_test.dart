// SDK harus tetap jalan tanpa Flutter binding (test Dart murni, isolate
// background). File ini sengaja TIDAK menginisialisasi binding apa pun.
import 'package:dio/dio.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';
import 'package:qiscus_chat_sdk/src/app_lifecycle.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/mqtt_broker.dart';

void main() {
  test('attach is a no-op without a binding and never initializes one', () {
    final resume = AppResumeSync(onResumed: () => true);
    expect(resume.attach(), isFalse);
    expect(resume.isAttached, isFalse);
    expect(maybeWidgetsBinding(), isNull);
    resume.detach();
  });

  test('login and manual resume work without a binding', () async {
    final sdk = QiscusSDK();
    final paths = <String>[];
    sdk.storage
      ..appId = 'resume-test'
      ..isRealtimeEnabled = false
      ..isSyncEventEnabled = true;
    sdk.dio.interceptors.add(InterceptorsWrapper(onRequest: (request, h) {
      final path = Uri.parse(request.path).path;
      paths.add(path);
      final data = path == 'login_or_register'
          ? {
              'results': {
                'user': {
                  'email': 'resume-user',
                  'username': 'resume-user',
                  'avatar_url': 'https://example.com/avatar.png',
                  'last_comment_id': 0,
                  'last_sync_event_id': 0,
                  'extras': '{}',
                  'token': 'resume-token',
                }
              }
            }
          : path == 'sync'
              ? {
                  'results': {
                    'meta': {'last_received_comment_id': 0},
                    'comments': <Object>[],
                  }
                }
              : {'events': <Object>[]};
      h.resolve(Response<Object>(
          requestOptions: request, statusCode: 200, data: data));
    }));
    addTearDown(() async {
      await sdk.clearUser();
      sdk.dio.close(force: true);
    });

    await sdk.setUser(userId: 'resume-user', userKey: 'resume-key');
    expect(maybeWidgetsBinding(), isNull);

    sdk.handleAppResumed();
    await waitFor(() => paths.contains('sync') && paths.contains('sync_event'));
  });
}
