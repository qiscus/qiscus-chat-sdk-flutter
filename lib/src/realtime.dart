import 'dart:async';

import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
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
    var isLogin = storage.isLogin;

    await for (var _ in stream) {
      if (storage.isSyncEnabled && isLogin) {
        try {
          var lastMessageId =
              storage.currentUser?.lastMessageId ?? storage.lastMessageId;
          var _data = await synchronizeImpl(lastMessageId.toString())
              .run(dio)
              .runOrThrow();

          if (_data.second.isNotEmpty || _data.first != 0) {
            storage.setLastMessageId(_data.first);
          }
          for (var message in _data.second) {
            yield message;
          }
        } catch (_) {}
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
        } catch (_) {}
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
    return StreamGroup.mergeBroadcast([
      messageReceivedSubs$.stream,
      _synchronize(),
      _mqttUpdates.transform(mqttMessageReceivedTransformer),
    ])
        .distinct((m1, m2) => m1.id == m2.id)
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
