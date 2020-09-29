part of qiscus_chat_sdk.usecase.realtime;

class RealtimeServiceImpl implements IRealtimeService {
  const RealtimeServiceImpl(this._mqttService, this._syncService);

  final MqttServiceImpl _mqttService;
  final SyncServiceImpl _syncService;

  @override
  bool get isConnected => _mqttService.isConnected;

  Task<Either<QError, void>> _subscribe(String topic) {
    if (_mqttService.isConnected) {
      return _mqttService.subscribe(topic);
    } else {
      return _syncService.subscribe(topic);
    }
  }

  Task<Either<QError, void>> _unsubscribe(String topic) {
    if (_mqttService.isConnected) {
      return _mqttService.subscribe(topic);
    } else {
      return _syncService.subscribe(topic);
    }
  }

  @override
  Task<Either<QError, void>> subscribe(String topic) => _subscribe(topic);

  @override
  Task<Either<QError, void>> unsubscribe(String topic) => _unsubscribe(topic);

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
  Stream<Message> subscribeChannelMessage({String uniqueId}) {
    return StreamGroup.merge([
      _mqttService.subscribeChannelMessage(uniqueId: uniqueId),
      _syncService.subscribeChannelMessage(uniqueId: uniqueId),
    ]);
  }

  @override
  Stream<Message> subscribeMessageDeleted() {
    return StreamGroup.merge([
      _mqttService.subscribeMessageDeleted(),
      _syncService.subscribeMessageDeleted(),
    ]);
  }

  @override
  Stream<Message> subscribeMessageDelivered({int roomId}) {
    return StreamGroup.merge([
      _mqttService.subscribeMessageDelivered(roomId: roomId),
      _syncService.subscribeMessageDelivered(roomId: roomId),
    ]);
  }

  @override
  Stream<Message> subscribeMessageRead({int roomId}) {
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
  Stream<ChatRoom> subscribeRoomCleared() {
    return StreamGroup.merge([
      _mqttService.subscribeRoomCleared(),
      _syncService.subscribeRoomCleared(),
    ]);
  }

  @override
  Stream<UserPresence> subscribeUserPresence({String userId}) {
    return _mqttService.subscribeUserPresence(userId: userId);
  }

  @override
  Stream<UserTyping> subscribeUserTyping({int roomId}) {
    return _mqttService.subscribeUserTyping(roomId: roomId);
  }

  @override
  Either<QError, void> end() {
    return right(null);
  }

  @override
  Stream<void> onConnected() => _mqttService.onConnected();

  @override
  Stream<void> onDisconnected() => _mqttService.onDisconnected();

  @override
  Stream<void> onReconnecting() => _mqttService.onReconnecting();

  @override
  Stream<CustomEvent> subscribeCustomEvent({int roomId}) =>
      _mqttService.subscribeCustomEvent(roomId: roomId);

  @override
  Either<QError, void> publishCustomEvent({
    @required int roomId,
    @required Map<String, dynamic> payload,
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
