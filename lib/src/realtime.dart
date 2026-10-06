import 'dart:async';

import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart' show protected;
import 'package:mqtt_client/mqtt_client.dart';

import 'core.dart';
import 'domain/domains.dart';
import 'impls/message/on-message-deleted-impl.dart';
import 'impls/message/on-message-delivered-impl.dart';
import 'impls/message/on-message-read-impl.dart';
import 'impls/message/on-message-received-impl.dart';
import 'impls/message/on-message-updated-impl.dart';
import 'impls/mqtt-impls.dart';
import 'impls/room/on-room-cleared.dart';
import 'impls/sync.dart';
import 'impls/user/is-authenticated-impl.dart';
import 'impls/user/on-user-presence-impl.dart';
import 'impls/user/on-user-typing-impl.dart';
import 'utils.dart';

mixin QRealtimeService {
  MqttClient get mqtt;
  Storage get storage;
  Dio get dio;

  late final Stream<QMqttMessage> _mqttUpdates =
      mqttUpdates().map((s) => s.transform(mqttExpandTransformer)).run(mqtt);

  // mqtt_client snapshots callbacks at connect. Initialize only the bridge,
  // leaving application message/receipt/typing streams lazy.
  @protected
  void initializeMqttUpdates() {
    _mqttUpdates;
  }

  /// Kegagalan pada jalur sinkronisasi REST - jalur cadangan yang dipakai saat
  /// koneksi realtime tidak mengirimkan apa pun.
  ///
  /// Sebelumnya semua error di sini ditelan `catch (_) {}`, sehingga aplikasi
  /// tidak punya cara apa pun untuk tahu bahwa jalur cadangannya sendiri
  /// sedang gagal.
  final StreamController<QError> realtimeErrors$ =
      StreamController<QError>.broadcast();

  Duration _interval() {
    if (storage.token == null) return storage.syncInterval;
    return mqtt.connectionStatus?.state == MqttConnectionState.connected
        ? storage.syncIntervalWhenConnected
        : storage.syncInterval;
  }

  Stream<void> interval$() async* {
    var accumulator = Duration(milliseconds: 0);
    var acc$ = Stream.periodic(
      storage.accSyncInterval,
      (_) => storage.accSyncInterval,
    );

    await for (var it in acc$) {
      accumulator += it;
      var interval = _interval();
      var shouldSync = accumulator >= interval;

      if (shouldSync) {
        yield null;
        accumulator = Duration(milliseconds: 0);
      }
    }
  }

  StreamTransformer<void, bool> _authenticatedTransformer(
    Tuple2<MqttClient, Storage> _deps,
  ) {
    return StreamTransformer.fromHandlers(handleData: (_, sink) async {
      var isLoggedIn = await waitTillAuthenticatedImpl.run(_deps).run();
      sink.add(isLoggedIn);
    });
  }

  Stream<QMessage> _synchronize() async* {
    var stream = interval$()
        .transform<bool>(_authenticatedTransformer(Tuple2(mqtt, storage)));

    await for (var _ in stream) {
      // `storage.isLogin` WAJIB dibaca di dalam loop.
      //
      // Sebelumnya nilainya dibaca sekali di luar loop dan disimpan ke
      // variabel lokal. Stream ini dibuat saat aplikasi pertama kali
      // memasang listener `onMessageReceived()` - yang pada mayoritas
      // aplikasi terjadi SEBELUM `setUser()` selesai. Akibatnya nilainya
      // terkunci `false` selamanya dan sinkronisasi REST tidak pernah jalan
      // seumur hidup proses, menghapus satu-satunya jaring pengaman saat
      // koneksi realtime bermasalah. Bandingkan `_synchronizeEvent()` di
      // bawah, yang sejak awal sudah membacanya di dalam loop.
      if (storage.isSyncEnabled && storage.isLogin) {
        try {
          var lastMessageId =
              storage.currentUser?.lastMessageId ?? storage.lastMessageId;
          var _data = await synchronizeImpl(lastMessageId.toString())
              .run(dio)
              .runOrThrow();

          if (_data.second.isNotEmpty || _data.first != 0) {
            storage.setLastMessageId(_data.first);
          }
          // Server mengirim batch dengan urutan menurun. Urutkan naik per
          // timestamp supaya aplikasi menerima pesan terlama lebih dulu.
          for (var message in _data.second.sortedByTimestamp()) {
            yield message;
          }
        } catch (error, stackTrace) {
          realtimeErrors$.add(
            QError('Message synchronization failed: $error', stackTrace),
          );
        }
      }
    }
  }

  Stream<QRealtimeEvent> _synchronizeEvent() async* {
    var stream =
        interval$().transform(_authenticatedTransformer(Tuple2(mqtt, storage)));

    await for (var _ in stream) {
      if (storage.isSyncEventEnabled && storage.isLogin) {
        try {
          var lastEventId =
              storage.currentUser?.lastEventId ?? storage.lastEventId;
          var data =
              await synchronizeEventImpl(lastEventId).run(dio).runOrThrow();

          if (data.second.isNotEmpty || data.first != 0) {
            storage.currentUser?.lastEventId = data.first;
            storage.lastEventId = data.first;
          }

          for (var event in data.second) {
            yield event;
          }
        } catch (error, stackTrace) {
          realtimeErrors$.add(
            QError('Event synchronization failed: $error', stackTrace),
          );
        }
      }
    }
  }

  Stream<QMessage> getMessageReceivedStream({
    required StreamController<QMessage> messageReceivedSubs$,
    required Future<void> Function(
            {required int roomId, required int messageId})
        markAsDelivered,
    required Future<T> Function<T>(QInterceptor, T) triggerHook,
  }) {
    // Dedupe per id, bukan `distinct`: `distinct` hanya membandingkan dengan
    // event sebelumnya, jadi `5,7,6,8,10,9,6` lolos semua (6 dobel). Pesan yang
    // sama datang dari MQTT dan dari sync, dan sync bisa mengirim ulang batch.
    var seen = _SeenMessageIds();
    return StreamGroup.mergeBroadcast([
      messageReceivedSubs$.stream,
      _synchronize(),
      _mqttUpdates.transform(mqttMessageReceivedTransformer),
    ])
        .where((m) => seen.add(m.id))
        .tap((it) =>
            markAsDelivered(roomId: it.chatRoomId, messageId: it.id).ignore())
        .asyncMap((it) => triggerHook(QInterceptor.messageBeforeReceived, it))
        .tap((m) => storage.setLastMessageId(m.id));
  }

  Stream<QMessage> getMessageReadStream() {
    return StreamGroup.mergeBroadcast([
      _synchronizeEvent().transform(syncMessageReadTransformerImpl),
      _mqttUpdates.transform(mqttMessageReadTransformerImpl),
    ])
        .map((it) => it.run(storage.messages))
        .tap((it) => storage.messages = it.second.toSet())
        .map((it) => it.first)
        .transform(nonNullTransformer());
  }

  Stream<QMessage> getMessageDeliveredStream() {
    return StreamGroup.mergeBroadcast([
      _synchronizeEvent().transform(syncMessageDeliveredTransformerImpl),
      _mqttUpdates.transform(mqttMessageDeliveredTransformerImpl),
    ])
        .map((it) => it.run(storage.messages))
        .tap((it) => storage.messages = it.second.toSet())
        .map((it) => it.first)
        .transform(nonNullTransformer());
  }

  Stream<QMessage> getMessageDeletedStream() {
    return StreamGroup.mergeBroadcast([
      _synchronizeEvent().transform(syncMessageDeletedTransformerImpl),
      _mqttUpdates.transform(mqttMessageDeletedTransformerImpl)
    ])
        .map((state) => state.run(storage.messages))
        .tap((it) => storage.messages = it.second.toSet())
        .map((it) => it.first)
        .transform(nonNullTransformer());
  }

  Stream<QMessage> getMessageUpdatedStream() {
    return _mqttUpdates
        .transform(mqttMessageUpdatedTransformerImpl)
        .map((state) => state.run(storage.messages))
        .tap((it) => storage.messages = it.second.toSet())
        .map((it) => it.first);
  }

  Stream<QUserTyping> getUserTypingStream() {
    return _mqttUpdates.transform(mqttUserTypingTransformerImpl);
  }

  Stream<QUserPresence> getUserPresenceStream() {
    return _mqttUpdates.transform(mqttUserPresenceTransformerImpl);
  }

  Stream<int> getRoomClearedStream() {
    return StreamGroup.mergeBroadcast([
      _synchronizeEvent().transform(syncRoomClearedTransformerImpl),
      _mqttUpdates.transform(mqttRoomClearedTransformerImpl),
    ]);
  }
}

/// Id pesan yang sudah diteruskan ke aplikasi. Dibatasi supaya tidak tumbuh
/// tanpa batas selama proses hidup; pesan lebih lama dari batas ini sudah
/// tertutup oleh cursor `lastMessageId`.
class _SeenMessageIds {
  static const _maxSize = 2000;

  final _ids = <int>{};

  /// `true` bila [id] baru (belum pernah dilihat).
  bool add(int id) {
    if (!_ids.add(id)) return false;
    if (_ids.length > _maxSize) _ids.remove(_ids.first);
    return true;
  }
}
