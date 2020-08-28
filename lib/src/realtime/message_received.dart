part of qiscus_chat_sdk.realtime;

class MessageReceivedEvent with IRealtimeEvent<Message> {
  final String userToken;
  const MessageReceivedEvent({@required this.userToken});

  @override
  Option<String> get mqttData => none();
  @override
  Option<String> get mqttTopic => some('$userToken/c');
  @override
  Option<RealtimeSyncTopic> get syncTopic =>
      some(RealtimeSyncTopic.messageReceived);

  @override
  Stream<Message> mqttMapper(String payload) async* {
    throw UnimplementedError();
  }

  @override
  Stream<Message> syncMapper(Map<String, dynamic> payload) async* {
    throw UnimplementedError();
  }
}
