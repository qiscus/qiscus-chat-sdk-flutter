import 'dart:async';

import 'package:dio/dio.dart';
import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';
import 'package:test/test.dart';

// Bug cursor sync Klikdokter (2.2.7): `lastMessageId` adalah SATU cursor
// global yang hanya boleh maju, dipakai `sync?last_received_comment_id=`.
// Dulu cursor ini ikut digeser oleh loader per room (getChatRoomWithMessages,
// getNext/PreviousMessagesById) dan sendMessage. Reproduksi: realtime
// melewatkan pesan 820 di room A, lalu user membuka room B yang berisi 825 ->
// cursor lompat ke 825 dan sync tidak pernah menarik 820, sehingga 820 tidak
// pernah sampai ke onMessageReceived() sampai user masuk ulang ke room A.

const _roomA = 1;
const _roomB = 2;
const _me = 'me-id';

Map<String, Object?> _comment(int id, int roomId, {String sender = 'other'}) =>
    <String, Object?>{
      'id': id,
      'room_id': roomId,
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

Map<String, Object?> _room(int id) => <String, Object?>{
      'id': id,
      'room_name': 'room-$id',
      'unique_id': 'unique-room-$id',
      'unread_count': 0,
      'avatar_url': 'https://example.com/room.png',
      'options': '{}',
      'chat_type': 'group',
      'is_public_channel': false,
    };

/// Server palsu: menyimpan semua komentar dan menjawab `sync` seperti server
/// asli, yaitu hanya komentar dengan id di atas cursor yang dikirim.
class FakeServer {
  FakeServer(this.sdk) {
    sdk.dio.interceptors.add(InterceptorsWrapper(onRequest: (request, handler) {
      requests.add(request.path);
      handler.resolve(Response<Map<String, Object?>>(
        requestOptions: request,
        statusCode: 200,
        data: _respond(request),
      ));
    }));
  }

  final QiscusSDK sdk;
  final comments = <Map<String, Object?>>[];

  /// Komentar milik user sendiri yang (secara hipotesis) ikut dikirim `sync`.
  final ownComments = <Map<String, Object?>>[];

  /// `sync` dengan cursor tertentu mengembalikan meta ini, bila diisi.
  int? forcedSyncMeta;
  final requests = <String>[];

  List<String> get syncRequests =>
      requests.where((it) => it.startsWith('sync')).toList();

  Map<String, Object?> _respond(RequestOptions request) {
    var uri = Uri.parse(request.path);
    var query = uri.queryParameters;
    switch (uri.path) {
      case 'sync':
        var cursor = int.tryParse(query['last_received_comment_id'] ?? '') ?? 0;
        var result = [...comments, ...ownComments]
            .where((c) => (c['id'] as int) > cursor)
            .toList()
          ..sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
        var meta = forcedSyncMeta ??
            (result.isEmpty ? cursor : result.first['id'] as int);
        return {
          'results': {
            'meta': {'last_received_comment_id': meta},
            'comments': result,
          }
        };
      case 'get_room_by_id':
        var roomId = int.parse(query['id']!);
        return {
          'results': {
            'room': _room(roomId),
            'comments': _commentsOf(roomId),
          }
        };
      case 'load_comments':
        var roomId = int.parse(query['topic_id']!);
        return {
          'results': {'comments': _commentsOf(roomId)}
        };
      case 'post_comment':
        var comment = _comment(830, _roomB, sender: _me);
        ownComments.add(comment);
        return {
          'results': {'comment': comment}
        };
      default:
        return {'results': <String, Object?>{}};
    }
  }

  List<Map<String, Object?>> _commentsOf(int roomId) =>
      comments.where((c) => c['room_id'] == roomId).toList();
}

QiscusSDK _sdk({required int cursor}) {
  var sdk = QiscusSDK();
  sdk.storage
    ..appId = 'sync-cursor-test'
    ..isRealtimeEnabled = false
    // Sync dinyalakan per test, supaya loader bisa dipanggil lebih dulu.
    ..isSyncEnabled = false
    ..syncInterval = const Duration(milliseconds: 100)
    ..syncIntervalWhenConnected = const Duration(milliseconds: 100)
    ..accSyncInterval = const Duration(milliseconds: 100)
    ..currentUser = QAccount(id: _me, name: 'me', lastMessageId: cursor)
    ..lastMessageId = cursor
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

void _expectCursor(QiscusSDK sdk, int cursor) {
  expect(sdk.storage.lastMessageId, cursor);
  expect(sdk.storage.currentUser?.lastMessageId, cursor);
}

void main() {
  group('room loaders do not move the sync cursor', () {
    late QiscusSDK sdk;
    late FakeServer server;

    setUp(() {
      sdk = _sdk(cursor: 810);
      server = FakeServer(sdk)
        ..comments.addAll([
          _comment(800, _roomB),
          _comment(820, _roomA),
          _comment(825, _roomB),
        ]);
    });

    test('getChatRoomWithMessages', () async {
      var data = await sdk.getChatRoomWithMessages(roomId: _roomB);
      expect(data.messages.map((m) => m.id), contains(825));
      _expectCursor(sdk, 810);
    });

    test('getNextMessagesById', () async {
      var messages =
          await sdk.getNextMessagesById(roomId: _roomB, messageId: 800);
      expect(messages.map((m) => m.id), contains(825));
      _expectCursor(sdk, 810);
    });

    test('getPreviousMessagesById', () async {
      var messages =
          await sdk.getPreviousMessagesById(roomId: _roomB, messageId: 900);
      expect(messages.map((m) => m.id), contains(825));
      _expectCursor(sdk, 810);
    });

    // Skenario reproduksi Klikdokter.
    test('a message missed in room A is still synced after opening room B',
        () async {
      await sdk.getChatRoomWithMessages(roomId: _roomB);
      await sdk.getNextMessagesById(roomId: _roomB, messageId: 800);
      await sdk.getPreviousMessagesById(roomId: _roomB, messageId: 900);

      var received = <int>[];
      var subs = sdk.onMessageReceived().listen((m) => received.add(m.id));
      addTearDown(subs.cancel);
      sdk.storage.isSyncEnabled = true;

      await _waitFor(() => server.syncRequests.length >= 3);
      expect(server.syncRequests.first, 'sync?last_received_comment_id=810');
      expect(received.where((id) => id == 820), hasLength(1));
      expect(received, [820, 825]);
      _expectCursor(sdk, 825);
    });
  });

  group('sendMessage', () {
    test('does not move the sync cursor', () async {
      var sdk = _sdk(cursor: 810);
      FakeServer(sdk);

      var sent = await sdk.sendMessage(
        message: sdk.generateMessage(chatRoomId: _roomB, text: 'hi'),
      );
      expect(sent.id, 830);
      _expectCursor(sdk, 810);
    });

    // Server tidak mengirim balik pesan milik user sendiri (lihat
    // tool/e2e.dart), dan dulu cursor yang digeser sendMessage juga mencegah
    // sync mengirimnya. Kalau sync tetap mengembalikannya, pesan yang dikirim
    // dari perangkat ini tidak boleh tiba-tiba muncul di onMessageReceived().
    test('own message sent from this device is not re-delivered by sync',
        () async {
      var sdk = _sdk(cursor: 810);
      var server = FakeServer(sdk)..comments.add(_comment(820, _roomA));

      await sdk.sendMessage(
        message: sdk.generateMessage(chatRoomId: _roomB, text: 'hi'),
      );

      var received = <int>[];
      var subs = sdk.onMessageReceived().listen((m) => received.add(m.id));
      addTearDown(subs.cancel);
      sdk.storage.isSyncEnabled = true;

      await _waitFor(() => server.syncRequests.length >= 3);
      expect(server.syncRequests.first, 'sync?last_received_comment_id=810');
      expect(received, [820]);
      // Cursor tetap maju sesuai hasil sync, termasuk melewati pesan sendiri.
      _expectCursor(sdk, 830);
    });
  });

  group('public synchronize()', () {
    test('without an argument uses the current cursor', () async {
      var sdk = _sdk(cursor: 810);
      var server = FakeServer(sdk)
        ..comments.addAll([_comment(820, _roomA), _comment(825, _roomB)]);

      sdk.synchronize();
      await _waitFor(() => sdk.storage.lastMessageId != 810);

      expect(server.syncRequests, ['sync?last_received_comment_id=810']);
      _expectCursor(sdk, 825);
    });

    test('uses the logged-in user cursor when storage is behind', () async {
      var sdk = _sdk(cursor: 810)..storage.lastMessageId = 0;
      var server = FakeServer(sdk);

      sdk.synchronize();
      await _waitFor(() => server.syncRequests.isNotEmpty);

      expect(server.syncRequests, ['sync?last_received_comment_id=810']);
    });

    test('with an explicit id never moves the cursor backwards', () async {
      var sdk = _sdk(cursor: 810);
      var server = FakeServer(sdk)..forcedSyncMeta = 790;

      sdk.synchronize(lastMessageId: '700');
      await _waitFor(() => server.syncRequests.isNotEmpty);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(server.syncRequests, ['sync?last_received_comment_id=700']);
      _expectCursor(sdk, 810);
    });

    test('updates currentUser.lastMessageId too', () async {
      var sdk = _sdk(cursor: 810);
      var server = FakeServer(sdk)..forcedSyncMeta = 900;

      sdk.synchronize(lastMessageId: '810');
      await _waitFor(() => server.syncRequests.isNotEmpty);
      await _waitFor(() => sdk.storage.currentUser?.lastMessageId == 900);

      _expectCursor(sdk, 900);
    });
  });
}
