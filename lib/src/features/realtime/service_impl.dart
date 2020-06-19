import 'package:async/async.dart';
import 'package:dartz/dartz.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/features/message/entity.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/mqtt_service_impl.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/service.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/sync_service_impl.dart';

class RealtimeServiceImpl implements RealtimeService {
  const RealtimeServiceImpl(this._mqttService, this._syncService);

  final MqttServiceImpl _mqttService;
  final SyncServiceImpl _syncService;

  @override
  bool get isConnected => _mqttService.isConnected;

  @override
  Task<Either<QError, void>> subscribe(String topic) =>
      _mqttService.subscribe(topic);

  @override
  Task<Either<QError, void>> unsubscribe(String topic) =>
      _mqttService.unsubscribe(topic);

  @override
  Either<QError, void> publishPresence({
    bool isOnline,
    DateTime lastSeen,
    String userId,
  }) {
    return _mqttService.publishPresence(
      isOnline: isOnline,
      lastSeen: lastSeen,
      userId: userId,
    );
  }

  @override
  Either<QError, void> publishTyping({
    bool isTyping,
    String userId,
    int roomId,
  }) {
    return _mqttService.publishTyping(
      isTyping: isTyping,
      roomId: roomId,
      userId: userId,
    );
  }

  @override
  Stream<MessageReceivedResponse> subscribeChannelMessage({String uniqueId}) {
    return StreamGroup.merge([
      _mqttService.subscribeChannelMessage(uniqueId: uniqueId),
      _syncService.subscribeChannelMessage(uniqueId: uniqueId),
    ]);
  }

  @override
  Stream<MessageDeletedResponse> subscribeMessageDeleted() {
    return StreamGroup.merge([
      _mqttService.subscribeMessageDeleted(),
      _syncService.subscribeMessageDeleted(),
    ]);
  }

  @override
  Stream<MessageDeliveryResponse> subscribeMessageDelivered({int roomId}) {
    return StreamGroup.merge([
      _mqttService.subscribeMessageDelivered(roomId: roomId),
      _syncService.subscribeMessageDelivered(roomId: roomId),
    ]);
  }

  @override
  Stream<MessageDeliveryResponse> subscribeMessageRead({int roomId}) {
    return StreamGroup.merge([
      _mqttService.subscribeMessageRead(roomId: roomId),
      _syncService.subscribeMessageRead(roomId: roomId),
    ]);
  }

  @override
  Stream<Message> subscribeMessageReceived() {
    return StreamGroup.merge([
      _mqttService.subscribeMessageReceived(),
      _syncService.subscribeMessageReceived(),
    ]);
  }

  @override
  Stream<RoomClearedResponse> subscribeRoomCleared() {
    return StreamGroup.merge([
      _mqttService.subscribeRoomCleared(),
      _syncService.subscribeRoomCleared(),
    ]);
  }

  @override
  Stream<UserPresenceResponse> subscribeUserPresence({String userId}) {
    return _mqttService.subscribeUserPresence(userId: userId);
  }

  @override
  Stream<UserTypingResponse> subscribeUserTyping({int roomId}) {
    return _mqttService.subscribeUserTyping(roomId: roomId);
  }

  @override
  Either<QError, void> end() {
    return right(null);
  }

  @override
  MqttClientConnectionStatus get connectionState =>
      _mqttService.connectionState;

  @override
  Stream<void> onConnected() => _mqttService.onConnected();

  @override
  Stream<void> onDisconnected() => _mqttService.onDisconnected();

  @override
  Stream<void> onReconnecting() => _mqttService.onReconnecting();

  @override
  Stream<CustomEventResponse> subscribeCustomEvent({int roomId}) =>
      _mqttService.subscribeCustomEvent(roomId: roomId);

  @override
  Either<QError, void> publishCustomEvent({
    int roomId,
    Map<String, dynamic> payload,
  }) {
    return _mqttService.publishCustomEvent(roomId: roomId, payload: payload);
  }

  @override
  Task<Either<QError, Unit>> synchronize([int lastMessageId]) {
    return _syncService.synchronize(lastMessageId);
  }

  @override
  Task<Either<QError, Unit>> synchronizeEvent([String lastEventId]) {
    return _syncService.synchronizeEvent(lastEventId);
  }
}
