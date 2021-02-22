part of qiscus_chat_sdk.usecase.realtime;

abstract class IRealtimeService {
  bool get isConnected;

  Future<void> connect();
  Future<void> end();

  Future<void> subscribe(String topic);
  Future<void> unsubscribe(String topic);
  Stream<void> onConnected();

  Stream<void> onReconnecting();

  Stream<void> onDisconnected();

  Stream<Message> subscribeMessageReceived();
  Stream<Message> subscribeMessageUpdated();

  Stream<Message> subscribeMessageDelivered({
    @required int roomId,
  });

  Stream<CustomEvent> subscribeCustomEvent({
    @required int roomId,
  });

  Stream<Message> subscribeMessageRead({
    @required int roomId,
  });

  Stream<Message> subscribeMessageDeleted();

  Stream<ChatRoom> subscribeRoomCleared();

  Stream<Message> subscribeChannelMessage({
    @required String uniqueId,
  });

  Stream<UserTyping> subscribeUserTyping({
    @required int roomId,
  });

  Stream<UserPresence> subscribeUserPresence({
    @required String userId,
  });
  Stream<Notification> subscribeNotification();

  Future<void> publishTyping({
    @required bool isTyping,
    @required String userId,
    @required int roomId,
  });

  Future<void> publishPresence({
    bool isOnline,
    DateTime lastSeen,
    String userId,
  });

  Future<void> publishCustomEvent({
    @required int roomId,
    @required Map<String, dynamic> payload,
  });

  Future<Either<QError, void>> synchronize([int lastMessageId]);
  Future<Either<QError, void>> synchronizeEvent([String lastEventId]);
}
