part of qiscus_chat_sdk.realtime;

class MessageDeliveredEvent with IRealtimeEvent<Message> {
  final Message message;

  const MessageDeliveredEvent({@required this.message});

  @override
  Option<String> get mqttData => none();

  @override
  Option<String> get mqttTopic => message.chatRoomId.foldMap(
        optionMi(semigroup((a1, a2) => a1 + a2)),
        (a) => some('$a'),
      );

  @override
  Option<RealtimeSyncTopic> get syncTopic =>
      some(RealtimeSyncTopic.messageDelivered);

  @override
  Stream<Message> mqttMapper(String payload) async* {
    throw UnimplementedError();
  }

  @override
  Stream<Message> syncMapper(Map<String, dynamic> payload) async* {
    throw UnimplementedError();
  }
}
