import 'dart:async';

import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart' show protected;
import 'package:mqtt_client/mqtt_client.dart';

import 'core.dart';
import 'domain/domains.dart';
import 'impls/message/message-receipt-impl.dart';
import 'impls/message/on-message-deleted-impl.dart';
import 'impls/message/on-message-delivered-impl.dart';
import 'impls/message/on-message-read-impl.dart';
import 'impls/message/on-message-received-impl.dart';
import 'impls/message/on-message-updated-impl.dart';
import 'impls/mqtt-impls.dart';
import 'impls/room/on-room-cleared.dart';
import 'impls/sync.dart';
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

  /// Id pesan yang dikirim aplikasi dari perangkat ini lewat `sendMessage()`.
  ///
  /// Dulu `sendMessage()` menggeser cursor sync ke id pesan yang baru dikirim,
  /// sehingga sync tidak pernah mengirim pesan sendiri ke `onMessageReceived()`
  /// (tapi juga melewatkan pesan orang lain yang belum tersinkron). Cursor kini
  /// hanya digeser oleh sync dan stream pesan masuk; set ini menjaga perilaku
  /// lama: pesan sendiri tidak dikirim ulang lewat jalur sync.
  final _sentMessageIds = _SeenMessageIds();

  @protected
  void registerSentMessageId(int messageId) {
    _sentMessageIds.add(messageId);
  }

  Duration _interval() {
    if (storage.token == null) return storage.syncInterval;
    return mqtt.connectionStatus?.state == MqttConnectionState.connected
        ? storage.syncIntervalWhenConnected
        : storage.syncInterval;
  }

  // Bukan `async*`: generator `async*` yang sedang menunggu di `await for`
  // baru berhenti (dan `cancel()`-nya baru selesai) saat mencapai `yield`
  // berikutnya. Stream.periodic berhenti seketika saat di-cancel.
  Stream<void> interval$() {
    var accumulator = Duration(milliseconds: 0);
    return Stream.periodic(
      storage.accSyncInterval,
      (_) => storage.accSyncInterval,
    ).where((it) {
      accumulator += it;
      if (accumulator < _interval()) return false;
      accumulator = Duration(milliseconds: 0);
      return true;
    });
  }

  /// Satu putaran sync REST tiap interval, hanya selama ada listener.
  ///
  /// Dulu ini generator `async*` dengan `await for`. `cancel()` pada generator
  /// seperti itu baru selesai saat body mencapai `yield` berikutnya - padahal
  /// loop ini jarang (atau, untuk sync event yang default-nya mati, tidak
  /// pernah) `yield`. Ditambah `StreamGroup.mergeBroadcast` sengaja tidak
  /// meng-cancel stream single-subscription saat listener terakhir pergi,
  /// sehingga loop dan request HTTP-nya jalan terus seumur proses. Sekarang
  /// stream-nya broadcast (di-cancel oleh `mergeBroadcast`) dan berhenti
  /// seketika: `asyncExpand` + `Stream.fromFuture` tidak menunggu `yield`.
  Stream<QMessage> _synchronize() {
    return _whileListened(() => interval$()
        // `storage.isLogin` WAJIB dibaca tiap putaran, bukan sekali saat stream
        // dibuat: stream ini biasanya dibuat SEBELUM `setUser()` selesai, dan
        // nilai yang terkunci `false` mematikan sync REST seumur proses.
        .where((_) => storage.isSyncEnabled && storage.isLogin)
        .asyncExpand((_) =>
            Stream.fromFuture(_synchronizeOnce()).expand((it) => it)));
  }

  Future<List<QMessage>> _synchronizeOnce() async {
    try {
      var lastMessageId =
          storage.currentUser?.lastMessageId ?? storage.lastMessageId;
      var _data =
          await synchronizeImpl(lastMessageId.toString()).run(dio).runOrThrow();

      if (_data.second.isNotEmpty || _data.first != 0) {
        storage.setLastMessageId(_data.first);
      }
      // Server mengirim batch dengan urutan menurun. Urutkan naik per
      // timestamp supaya aplikasi menerima pesan terlama lebih dulu.
      return _data.second.sortedByTimestamp();
    } catch (error, stackTrace) {
      realtimeErrors$.add(
        QError('Message synchronization failed: $error', stackTrace),
      );
      return [];
    }
  }

  /// Satu loop `sync_event` bersama untuk stream read/delivered/deleted/
  /// cleared. Dulu tiap stream punya loop sendiri yang sama-sama menggeser
  /// `lastEventId`, sehingga event yang diambil satu loop terlewat oleh loop
  /// lain. Lihat juga [_synchronize] soal cancel.
  late final Stream<QRealtimeEvent> _syncEvent$ = _whileListened(() =>
      interval$()
          .where((_) => storage.isSyncEventEnabled && storage.isLogin)
          .asyncExpand((_) =>
              Stream.fromFuture(_synchronizeEventOnce()).expand((it) => it)));

  Stream<QRealtimeEvent> _synchronizeEvent() => _syncEvent$;

  Future<List<QRealtimeEvent>> _synchronizeEventOnce() async {
    try {
      var lastEventId = storage.currentUser?.lastEventId ?? storage.lastEventId;
      var data = await synchronizeEventImpl(lastEventId).run(dio).runOrThrow();

      if (data.second.isNotEmpty || data.first != 0) {
        storage.currentUser?.lastEventId = data.first;
        storage.lastEventId = data.first;
      }
      return data.second.toList();
    } catch (error, stackTrace) {
      realtimeErrors$.add(
        QError('Event synchronization failed: $error', stackTrace),
      );
      return [];
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
      messageReceivedSubs$.stream.where(_isNotSentHere),
      _synchronize().where(_isNotSentHere),
      _mqttUpdates.transform(mqttMessageReceivedTransformer),
    ])
        .where((m) => seen.add(m.id))
        .tap((it) =>
            markAsDelivered(roomId: it.chatRoomId, messageId: it.id).ignore())
        .asyncMap((it) => triggerHook(QInterceptor.messageBeforeReceived, it))
        // Daftarkan ke store supaya event deleted/updated/status berikutnya
        // untuk pesan ini bisa dicocokkan.
        .tap((m) => storage.messages = {...storage.messages, m})
        .tap((m) => storage.setLastMessageId(m.id));
  }

  bool _isNotSentHere(QMessage message) =>
      !_sentMessageIds.contains(message.id);

  /// Status delivered/read hanya bermakna untuk pesan milik user sendiri.
  ///
  /// Store kini juga berisi pesan yang dimuat dan diterima, termasuk milik
  /// user lain. Receipt atas pesan mereka (mis. dari `markAsDelivered`
  /// otomatis) tidak diteruskan, sama seperti sebelum store diisi pesan
  /// selain hasil `sendMessage`.
  bool _isOwnMessage(QMessage message) =>
      message.sender.id == storage.currentUser?.id;

  Stream<QMessage> getMessageReadStream() {
    return StreamGroup.mergeBroadcast([
      _synchronizeEvent().transform(syncMessageReadTransformerImpl),
      _mqttUpdates.transform(mqttMessageReadTransformerImpl),
    ]).transform(_applyReceipts());
  }

  Stream<QMessage> getMessageDeliveredStream() {
    return StreamGroup.mergeBroadcast([
      _synchronizeEvent().transform(syncMessageDeliveredTransformerImpl),
      _mqttUpdates.transform(mqttMessageDeliveredTransformerImpl),
    ]).transform(_applyReceipts());
  }

  /// Terapkan tiap receipt ke store (dengan cascade, lihat
  /// [applyMessageReceipt]) dan emit satu event per pesan yang statusnya
  /// berubah, terlama dulu.
  ///
  /// Penerapan wajib terjadi sekali per receipt, jadi memakai `asyncMap`: pada
  /// stream broadcast ia hanya subscribe sekali ke sumbernya, sedangkan
  /// `map`/`expand` dijalankan ulang per listener - listener kedua tidak akan
  /// melihat perubahan apa pun bila penerapannya ada di sana.
  StreamTransformer<MessageReceipt, QMessage> _applyReceipts() {
    return StreamTransformer.fromBind((receipts) {
      return receipts
          .asyncMap((receipt) => applyMessageReceipt(
                storage.messages,
                receipt,
                currentUserId: storage.currentUser?.id,
              ))
          .expand((it) => it)
          .where(_isOwnMessage);
    });
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

/// Stream broadcast yang menjalankan [source] hanya selama ada listener:
/// di-listen saat listener pertama datang, di-cancel saat listener terakhir
/// pergi, dan dibuat ulang bila ada listener lagi.
///
/// `StreamGroup.mergeBroadcast` hanya meng-cancel stream anggota yang
/// broadcast; stream single-subscription dibiarkan jalan terus.
Stream<T> _whileListened<T>(Stream<T> Function() source) {
  StreamSubscription<T>? subscription;
  late StreamController<T> controller;
  controller = StreamController<T>.broadcast(
    onListen: () {
      subscription = source().listen(
        controller.add,
        onError: controller.addError,
      );
    },
    onCancel: () {
      subscription?.cancel().ignore();
      subscription = null;
    },
  );
  return controller.stream;
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

  bool contains(int id) => _ids.contains(id);
}
