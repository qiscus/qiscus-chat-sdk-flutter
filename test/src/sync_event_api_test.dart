import 'dart:async';

import 'package:dio/dio.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';
import 'package:test/test.dart';

// `synchronize()`/`synchronizeEvent()` publik (dipanggil aplikasi, dan oleh
// SDK sendiri saat resume). Dulu `synchronizeEvent()` membuang hasilnya: event
// delivered/read/deleted/clear room tidak pernah sampai ke stream SDK dan
// cursor event tidak maju. Selain itu request yang gagal lolos sebagai
// uncaught async error karena keduanya `void ... async`.

const _me = 'me-id';
const _room = 2;

Map<String, Object?> _comment(int id, {String sender = _me}) =>
    <String, Object?>{
      'id': id,
      'room_id': _room,
      'comment_before_id': id - 1,
      'unique_temp_id': 'unique-$id',
      'message': 'message-$id',
      'type': 'text',
      'status': 'sent',
      'unix_nano_timestamp': 1600000000000000000 + id * 1000000000,
      'email': sender,
      'username': '$sender-name',
      'user_avatar_url': 'https://example.com/avatar.png',
    };

Map<String, Object?> _receipt(int eventId, String action, int commentId) =>
    <String, Object?>{
      'id': eventId,
      'action_topic': action,
      'payload': {
        'data': {
          'comment_id': commentId,
          'comment_unique_id': 'unique-$commentId',
          'room_id': _room,
          'email': 'other',
        }
      },
    };

Map<String, Object?> _deleted(int eventId, int commentId) => <String, Object?>{
      'id': eventId,
      'action_topic': 'delete_message',
      'payload': {
        'deleted_messages': [
          {
            'room_id': '$_room',
            'message_unique_ids': ['unique-$commentId'],
          }
        ],
      },
    };

Map<String, Object?> _cleared(int eventId) => <String, Object?>{
      'id': eventId,
      'action_topic': 'clear_room',
      'payload': {
        'deleted_rooms': [
          {'id': _room}
        ],
      },
    };

class FakeServer {
  FakeServer(this.sdk) {
    sdk.dio.interceptors.add(InterceptorsWrapper(onRequest: (request, handler) {
      // Interceptor SDK sudah memindahkan query parameter ke `path`.
      var uri = Uri.parse(request.path);
      requests.add(uri);
      if (failWith != null && uri.path.startsWith('sync')) {
        handler.reject(DioException.badResponse(
          statusCode: failWith!,
          requestOptions: request,
          response: Response<Object>(
            requestOptions: request,
            statusCode: failWith,
            data: {'error': 'server error'},
          ),
        ));
        return;
      }
      handler.resolve(Response<Object>(
        requestOptions: request,
        statusCode: 200,
        data: _respond(uri),
      ));
    }));
  }

  final QiscusSDK sdk;
  final requests = <Uri>[];
  final events = <Map<String, Object?>>[];
  final comments = <Map<String, Object?>>[];

  /// Bila diisi, request `sync`/`sync_event` gagal dengan status ini.
  int? failWith;

  /// Bila `true`, `sync`/`sync_event` menjawab 200 dengan body tak terduga.
  bool malformed = false;

  /// Bila `true`, `sync_event` mengembalikan semua event tanpa melihat cursor.
  bool ignoreCursor = false;

  List<Uri> path(String p) => requests.where((r) => r.path == p).toList();

  Object _respond(Uri uri) {
    var query = uri.queryParameters;
    if (malformed && uri.path.startsWith('sync')) return <String, Object?>{};
    switch (uri.path) {
      case 'sync_event':
        var cursor = int.tryParse(query['start_event_id'] ?? '') ?? 0;
        return {
          'events': ignoreCursor
              ? events
              : events.where((e) => (e['id'] as int) > cursor).toList(),
        };
      case 'sync':
        return {
          'results': {
            'meta': {'last_received_comment_id': 0},
            'comments': <Object>[],
          }
        };
      case 'get_room_by_id':
        return {
          'results': {
            'room': {
              'id': _room,
              'room_name': 'room',
              'unique_id': 'unique-room',
              'unread_count': 0,
              'avatar_url': 'https://example.com/room.png',
              'options': '{}',
              'chat_type': 'group',
              'is_public_channel': false,
            },
            'comments': comments,
          }
        };
      default:
        return {'results': <String, Object?>{}};
    }
  }
}

QiscusSDK _sdk({required int eventCursor}) {
  var sdk = QiscusSDK();
  sdk.storage
    ..appId = 'sync-event-api-test'
    ..isRealtimeEnabled = false
    // Loop periodik dimatikan: semua event di test ini harus datang dari
    // pemanggilan `synchronizeEvent()` publik.
    ..isSyncEnabled = false
    ..isSyncEventEnabled = false
    ..syncInterval = const Duration(milliseconds: 100)
    ..syncIntervalWhenConnected = const Duration(milliseconds: 100)
    ..accSyncInterval = const Duration(milliseconds: 100)
    ..currentUser = QAccount(id: _me, name: 'me', lastEventId: eventCursor)
    ..lastEventId = eventCursor
    ..token = 'a-token';
  return sdk;
}

Future<void> _waitFor(bool Function() condition) async {
  var deadline = DateTime.now().add(const Duration(seconds: 5));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('condition not met');
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 150));

void _expectCursor(QiscusSDK sdk, int cursor) {
  expect(sdk.storage.lastEventId, cursor);
  expect(sdk.storage.currentUser?.lastEventId, cursor);
}

void main() {
  group('public synchronizeEvent()', () {
    test('without an argument uses the current cursor and advances it',
        () async {
      var sdk = _sdk(eventCursor: 40);
      var server = FakeServer(sdk)
        ..events
            .addAll([_receipt(41, 'delivered', 1), _receipt(45, 'read', 1)]);

      sdk.synchronizeEvent();
      await _waitFor(() => server.path('sync_event').isNotEmpty);
      await _waitFor(() => sdk.storage.lastEventId != 40);

      expect(server.path('sync_event').single.queryParameters,
          {'start_event_id': '40'});
      _expectCursor(sdk, 45);
    });

    test('uses the logged-in user cursor when storage is behind', () async {
      var sdk = _sdk(eventCursor: 40)..storage.lastEventId = 0;
      var server = FakeServer(sdk);

      sdk.synchronizeEvent();
      await _waitFor(() => server.path('sync_event').isNotEmpty);

      expect(server.path('sync_event').single.queryParameters,
          {'start_event_id': '40'});
    });

    test('with an explicit id never moves the cursor backwards', () async {
      var sdk = _sdk(eventCursor: 50);
      var server = FakeServer(sdk)..events.add(_receipt(30, 'read', 1));

      sdk.synchronizeEvent(lastEventId: '10');
      await _waitFor(() => server.path('sync_event').isNotEmpty);
      await _settle();

      expect(server.path('sync_event').single.queryParameters,
          {'start_event_id': '10'});
      _expectCursor(sdk, 50);
    });

    test('an empty response does not reset the cursor', () async {
      var sdk = _sdk(eventCursor: 50);
      var server = FakeServer(sdk);

      sdk.synchronizeEvent();
      await _waitFor(() => server.path('sync_event').isNotEmpty);
      await _settle();

      _expectCursor(sdk, 50);
    });

    test('emits delivered, read and deleted events once on the SDK streams',
        () async {
      var sdk = _sdk(eventCursor: 40);
      var server = FakeServer(sdk)
        ..comments.addAll([_comment(1), _comment(2), _comment(3)]);
      await sdk.getChatRoomWithMessages(roomId: _room);

      var delivered = <int>[], read = <int>[], deleted = <int>[];
      var subs = [
        sdk.onMessageDelivered().listen((m) => delivered.add(m.id)),
        sdk.onMessageRead().listen((m) => read.add(m.id)),
        sdk.onMessageDeleted().listen((m) => deleted.add(m.id)),
      ];
      addTearDown(() => Future.wait(subs.map((s) => s.cancel())));

      server.events.addAll([
        _receipt(41, 'delivered', 1),
        _receipt(42, 'read', 2),
        _deleted(43, 3),
      ]);
      sdk.synchronizeEvent();
      await _waitFor(() => deleted.isNotEmpty);
      await _settle();

      expect(delivered, [1]);
      // Receipt read untuk 2 ikut menaikkan pesan sendiri sebelumnya di room
      // yang sama (cascade, lihat `applyMessageReceipt`).
      expect(read, [1, 2]);
      expect(deleted, [3]);
      _expectCursor(sdk, 43);
    });

    test('emits room cleared events', () async {
      var sdk = _sdk(eventCursor: 40);
      var server = FakeServer(sdk);

      var cleared = <int>[];
      var sub = sdk.onChatRoomCleared().listen(cleared.add);
      addTearDown(sub.cancel);

      server.events.add(_cleared(41));
      sdk.synchronizeEvent();
      await _waitFor(() => cleared.isNotEmpty);
      await _settle();

      expect(cleared, [_room]);
    });
  });

  group('periodic event sync', () {
    test('never moves the cursor backwards', () async {
      var sdk = _sdk(eventCursor: 50);
      var server = FakeServer(sdk)
        ..ignoreCursor = true
        ..events.add(_receipt(30, 'read', 1));

      var sub = sdk.onMessageRead().listen((_) {});
      addTearDown(sub.cancel);
      sdk.storage.isSyncEventEnabled = true;

      await _waitFor(() => server.path('sync_event').length >= 2);
      sdk.storage.isSyncEventEnabled = false;

      _expectCursor(sdk, 50);
    });
  });

  group('failures go to onRealtimeError() only', () {
    Future<List<Object>> runGuarded(
      QiscusSDK sdk,
      void Function() body,
      bool Function() done,
    ) async {
      var uncaught = <Object>[];
      runZonedGuarded(body, (error, _) => uncaught.add(error));
      await _waitFor(() => done() || uncaught.isNotEmpty);
      await _settle();
      return uncaught;
    }

    for (var failure in ['HTTP 500', 'malformed body']) {
      void arrange(FakeServer server) {
        if (failure == 'HTTP 500') {
          server.failWith = 500;
        } else {
          server.malformed = true;
        }
      }

      test('synchronize() on $failure', () async {
        var sdk = _sdk(eventCursor: 40);
        arrange(FakeServer(sdk));
        var errors = <QError>[];
        var sub = sdk.onRealtimeError().listen(errors.add);
        addTearDown(sub.cancel);

        var uncaught =
            await runGuarded(sdk, sdk.synchronize, () => errors.isNotEmpty);

        expect(uncaught, isEmpty);
        expect(errors, hasLength(1));
      });

      test('synchronizeEvent() on $failure', () async {
        var sdk = _sdk(eventCursor: 40);
        arrange(FakeServer(sdk));
        var errors = <QError>[];
        var sub = sdk.onRealtimeError().listen(errors.add);
        addTearDown(sub.cancel);

        var uncaught = await runGuarded(
            sdk, sdk.synchronizeEvent, () => errors.isNotEmpty);

        expect(uncaught, isEmpty);
        expect(errors, hasLength(1));
        _expectCursor(sdk, 40);
      });
    }
  });
}
