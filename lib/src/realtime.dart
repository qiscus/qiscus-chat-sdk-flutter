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

Duration _interval({
  required Storage storage,
  required MqttClient mqtt,
}) {
  if (storage.token == null) return storage.syncInterval;
  return mqtt.connectionStatus?.state == MqttConnectionState.connected
      ? storage.syncIntervalWhenConnected
      : storage.syncInterval;
}

Stream<void> interval$({
  required Storage storage,
  required MqttClient mqtt,
}) async* {
  var accumulator = Duration(milliseconds: 0);
  var acc$ = Stream.periodic(
    storage.accSyncInterval,
    (_) => storage.accSyncInterval,
  );

  await for (var it in acc$) {
    accumulator += it;
    var interval = _interval(storage: storage, mqtt: mqtt);
    var shouldSync = accumulator >= interval;

    if (shouldSync) {
      yield null;
      accumulator = Duration(milliseconds: 0);
    }
  }
}

StreamTransformer<void, bool> _authenticatedTransformer(
  Tuple2<MqttClient, Storage> _deps,
) =>
    StreamTransformer.fromHandlers(handleData: (_, sink) async {
      var isLoggedIn = await waitTillAuthenticatedImpl.run(_deps).run();
      sink.add(isLoggedIn);
    });

Stream<QMessage> synchronize({
  required Storage storage,
  required MqttClient mqtt,
  required Dio dio,
}) async* {
  var stream = interval$(
    mqtt: mqtt,
    storage: storage,
  ).transform<bool>(_authenticatedTransformer(Tuple2(mqtt, storage)));
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

Stream<QMqttMessage> getMqttUpdates(MqttClient mqtt) =>
    mqttUpdates().map((s) => s.transform(mqttExpandTransformer)).run(mqtt);

Stream<QMessage> getMessageReceivedStream({
  required MqttClient mqtt,
  required Dio dio,
  required Storage storage,
  required StreamController<QMessage> messageReceivedSubs$,
  required Future<void> Function({required int roomId, required int messageId})
      markAsDelivered,
  required Future<T> Function<T>(QInterceptor, T) triggerHook,
}) {
  return StreamGroup.mergeBroadcast([
    messageReceivedSubs$.stream,
    synchronize(dio: dio, mqtt: mqtt, storage: storage),
    getMqttUpdates(mqtt).transform(mqttMessageReceivedTransformer),
  ])
      .distinct((m1, m2) => m1.id == m2.id)
      .tap((it) =>
          markAsDelivered(roomId: it.chatRoomId, messageId: it.id).ignore())
      .asyncMap((it) => triggerHook(QInterceptor.messageBeforeReceived, it))
      .tap((m) => storage.setLastMessageId(m.id));
}

Stream<QMessage> getMessageReadStream({
  required Dio dio,
  required MqttClient mqtt,
  required Storage storage,
}) =>
    StreamGroup.mergeBroadcast([
      synchronizeEvent(dio: dio, storage: storage, mqtt: mqtt)
          .transform(syncMessageReadTransformerImpl),
      getMqttUpdates(mqtt).transform(mqttMessageReadTransformerImpl),
    ])
        .map((it) => it.run(storage.messages))
        .tap((it) => storage.messages = it.second.toSet())
        .map((it) => it.first)
        .transform(nonNullTransformer());

Stream<QMessage> getMessageDeliveredStream({
  required MqttClient mqtt,
  required Dio dio,
  required Storage storage,
}) =>
    StreamGroup.mergeBroadcast([
      synchronizeEvent(mqtt: mqtt, dio: dio, storage: storage)
          .transform(syncMessageDeliveredTransformerImpl),
      getMqttUpdates(mqtt).transform(mqttMessageDeliveredTransformerImpl),
    ])
        .map((it) => it.run(storage.messages))
        .tap((it) => storage.messages = it.second.toSet())
        .map((it) => it.first)
        .transform(nonNullTransformer());

Stream<QRealtimeEvent> synchronizeEvent({
  required MqttClient mqtt,
  required Storage storage,
  required Dio dio,
}) async* {
  var stream = interval$(mqtt: mqtt, storage: storage)
      .transform(_authenticatedTransformer(Tuple2(mqtt, storage)));

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

Stream<QMessage> getMessageDeletedStream({
  required MqttClient mqtt,
  required Dio dio,
  required Storage storage,
}) =>
    StreamGroup.mergeBroadcast([
      synchronizeEvent(mqtt: mqtt, storage: storage, dio: dio)
          .transform(syncMessageDeletedTransformerImpl),
      getMqttUpdates(mqtt).transform(mqttMessageDeletedTransformerImpl)
    ])
        .map((state) => state.run(storage.messages))
        .tap((it) => storage.messages = it.second.toSet())
        .map((it) => it.first)
        .transform(nonNullTransformer());

Stream<QMessage> getMessageUpdatedStream({
  required MqttClient mqtt,
  required Storage storage,
}) =>
    getMqttUpdates(mqtt)
        .transform(mqttMessageUpdatedTransformerImpl)
        .map((state) => state.run(storage.messages))
        .tap((it) => storage.messages = it.second.toSet())
        .map((it) => it.first);

Stream<QUserTyping> getUserTypingStream({required MqttClient mqtt}) =>
    getMqttUpdates(mqtt).transform(mqttUserTypingTransformerImpl);

Stream<QUserPresence> getUserPresenceStream({required MqttClient mqtt}) =>
    getMqttUpdates(mqtt).transform(mqttUserPresenceTransformerImpl);

Stream<int> getRoomClearedStream({
  required Dio dio,
  required MqttClient mqtt,
  required Storage storage,
}) =>
    StreamGroup.mergeBroadcast([
      synchronizeEvent(dio: dio, mqtt: mqtt, storage: storage)
          .transform(syncRoomClearedTransformerImpl),
      getMqttUpdates(mqtt).transform(mqttRoomClearedTransformerImpl),
    ]);
