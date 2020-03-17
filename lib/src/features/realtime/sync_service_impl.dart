import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';
import 'package:qiscus_chat_sdk/src/core/storage.dart';
import 'package:qiscus_chat_sdk/src/features/message/entity.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/interval.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/service.dart';
import 'package:qiscus_chat_sdk/src/features/sync/api.dart';

class SyncServiceImpl implements RealtimeService {
  SyncServiceImpl(
    this._s,
    this._api,
    this._interval,
  ) {
    //
    _syncController.addStream(_sync$);
    _syncEventController.addStream(_syncEvent$);
  }

  final SyncApi _api;
  final Storage _s;
  final Interval _interval;

  int get _messageId => _s.lastMessageId ?? 0;
  int get _eventId => _s.lastEventId ?? 0;

  @override
  Task<Either<Exception, void>> subscribe(String topic) {
    return Task.delay(() => left(Exception('Not supported')));
  }

  // region Producer
  Stream<SynchronizeEventResponse> get _syncEvent$ => _interval$
      .map((_) => _api.synchronizeEvent(_eventId).asStream())
      .flatten();
  Stream<SynchronizeResponseSingle> get _sync$ => _interval$
      .map((_) => _api.synchronize(_messageId).asStream())
      .flatten()
      .tap((res) {
        if (res.lastMessageId > _s.lastMessageId) {
          _s.lastMessageId = res.lastMessageId;
        }
      })
      .asyncMap((res) => Stream.fromIterable(res.messages //
          .map((msg) => SynchronizeResponseSingle(res.lastMessageId, msg))))
      .asyncExpand((it) => it)
      .asBroadcastStream();

  StreamController<SynchronizeResponseSingle> get _syncController =>
      StreamController.broadcast();
  StreamController<SynchronizeEventResponse> get _syncEventController =>
      StreamController.broadcast();
  // endregion

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
  Stream<MessageDeliveryResponse> subscribeMessageRead({int roomId}) {
    return synchronizeEvent(_s.lastEventId)
        .tap((res) => print('read: :- $res'))
        .where((res) {
      return res.actionType == 'read' && res.roomId == roomId;
    }).map((res) {
      return MessageDeliveryResponse(
        commentId: res.message.id.toString(),
        commentUniqueId: res.message.uniqueId.toString(),
        roomId: res.roomId,
      );
    });
  }

  @override
  Stream<Message> subscribeMessageReceived({int roomId}) {
    return synchronize(() => _s.lastMessageId).asyncMap((it) => it.message);
  }

  @override
  Stream<RoomClearedResponse> subscribeRoomCleared() {
    return synchronizeEvent(_s.lastEventId)
        .asyncMap((event) => RoomClearedResponse(room_id: event.roomId));
  }

  Stream<SynchronizeResponseSingle> synchronize([int Function() getMessageId]) {
    return _syncController.stream;
  }

  Stream<SynchronizeEventResponse> synchronizeEvent([int eventId = 0]) {
    return _syncEventController.stream;
  }

  @override
  bool get isConnected => true;

  @override
  MqttClientConnectionStatus get connectionState => null;

  Stream<Unit> get _interval$ => _interval.interval();

  // region Not implemented on sync adapter
  @override
  Stream<UserPresenceResponse> subscribeUserPresence({String userId}) {
    return null;
  }

  @override
  Stream<UserTypingResponse> subscribeUserTyping({String userId, int roomId}) {
    return null;
  }

  @override
  Either<Exception, void> publishPresence({
    bool isOnline,
    DateTime lastSeen,
    String userId,
  }) {
    return left(Exception('Not available for this service'));
  }

  @override
  Either<Exception, void> publishTyping({
    bool isTyping,
    String userId,
    int roomId,
  }) {
    return left(Exception('Not available for this service'));
  }

  @override
  Either<Exception, void> end() {
    return left(Exception('Not available for this service'));
  }
// endregion
}
