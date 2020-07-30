import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';
import 'package:qiscus_chat_sdk/src/core/storage.dart';
import 'package:qiscus_chat_sdk/src/features/message/entity.dart';

import 'api.dart';
import 'interval.dart';
import 'service.dart';

class SyncServiceImpl implements IRealtimeService {
  SyncServiceImpl(
    this._s,
    this._api,
    this._interval,
    this._logger,
  );

  final Logger _logger;
  final SyncApi _api;
  final Storage _s;
  final Interval _interval;

  int get _messageId => _s.lastMessageId ?? 0;

  int get _eventId => _s.lastEventId ?? 0;

  void log(String str) => _logger.log('SyncServiceImpl::- $str');

  // region Producer
  Stream<SyncEventResponseSingle> get _syncEvent$ => _interval$
          .map((_) => _api.synchronizeEvent(_eventId).asStream())
          .flatten()
          .expand((event) => event.events)
          .tap((_) => log('QiscusSyncAdapter: synchronize-event'))
      //
      ;

  Stream<SynchronizeResponseSingle> get _sync$ => _interval$
      .map((_) => _api.synchronize(_messageId).asStream())
      .flatten()
      .tap((res) {
        if (res.lastMessageId > _s.lastMessageId) {
          _s.lastMessageId = res.lastMessageId;
        }
      })
      .asyncMap((res) => Stream.fromIterable(res.messages
          .map((msg) => SynchronizeResponseSingle(res.lastMessageId, msg))))
      .tap((_) => log('QiscusSyncAdapter: synchronize'))
      .asyncExpand((it) => it)
      .asBroadcastStream();

  // endregion

  @override
  Stream<MessageDeliveryResponse> subscribeMessageRead({int roomId}) {
    return _synchronizeEvent(_s.lastEventId)
        .where((res) =>
            res.actionType == SyncActionType.messageRead &&
            res.roomId == roomId)
        .tap((data) => print('message read: $data'))
        .map((res) => MessageDeliveryResponse(
              commentId: res.message.id.toString(),
              commentUniqueId: res.message.uniqueId.toString(),
              roomId: res.roomId,
            ));
  }

  @override
  Stream<Message> subscribeMessageReceived({int roomId}) {
    return _synchronize(() => _s.lastMessageId) //
        .asyncMap((it) => it.message);
  }

  @override
  Stream<RoomClearedResponse> subscribeRoomCleared() {
    return _synchronizeEvent(_s.lastEventId)
        .asyncMap((event) => RoomClearedResponse(room_id: event.roomId));
  }

  @override
  Task<Either<QError, Unit>> synchronize([int lastMessageId]) {
    return Task(() => _api.synchronize(lastMessageId))
        .attempt()
        .leftMapToQError()
        .rightMap((_) => unit);
  }

  @override
  Task<Either<QError, Unit>> synchronizeEvent([String eventId]) {
    return Task(() => _api.synchronizeEvent(int.parse(eventId)))
        .attempt()
        .leftMapToQError()
        .rightMap((_) => unit);
  }

  Stream<SynchronizeResponseSingle> _synchronize([
    int Function() getMessageId,
  ]) {
    return _sync$;
  }

  Stream<SyncEventResponseSingle> _synchronizeEvent([int eventId = 0]) {
    return _syncEvent$;
  }

  @override
  bool get isConnected => true;

  @override
  MqttClientConnectionStatus get connectionState => null;

  Stream<Unit> get _interval$ => _interval.interval();

  // region Not implemented on sync adapter

  @override
  Stream<MessageReceivedResponse> subscribeChannelMessage({String uniqueId}) {
    return Stream.empty();
  }

  @override
  Stream<MessageDeletedResponse> subscribeMessageDeleted() {
    return Stream.empty();
  }

  @override
  Stream<MessageDeliveryResponse> subscribeMessageDelivered({int roomId}) {
    return Stream.empty();
  }

  @override
  Stream<UserPresenceResponse> subscribeUserPresence({String userId}) {
    return null;
  }

  @override
  Task<Either<QError, void>> subscribe(String topic) =>
      Task.delay(() => left(QError('Not supported')));

  @override
  Stream<UserTypingResponse> subscribeUserTyping({String userId, int roomId}) {
    return Stream.empty();
  }

  @override
  Either<QError, void> publishPresence({
    bool isOnline,
    DateTime lastSeen,
    String userId,
  }) {
    return left(QError('Not available for this service'));
  }

  @override
  Either<QError, void> publishTyping({
    bool isTyping,
    String userId,
    int roomId,
  }) {
    return left(QError('Not available for this service'));
  }

  @override
  Either<QError, void> end() {
    _interval.stop();
    return right(null);
  }

  @override
  Stream<void> onConnected() => Stream.empty();

  @override
  Stream<void> onDisconnected() => Stream.empty();

  @override
  Stream<void> onReconnecting() => Stream.empty();

  @override
  Stream<CustomEventResponse> subscribeCustomEvent({int roomId}) =>
      Stream.empty();

  @override
  Either<QError, void> publishCustomEvent({
    int roomId,
    Map<String, dynamic> payload,
  }) {
    return left<QError, void>(QError('Not implemented'));
  }

  @override
  Task<Either<QError, void>> unsubscribe(String topic) =>
      Task.delay(() => left<QError, void>(QError('Not implemented')));
// endregion
}
