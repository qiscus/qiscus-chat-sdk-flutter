part of qiscus_chat_sdk.realtime;

class MqttUserTyping
    implements IMqttReceive<UserTyping>, IMqttPublish<UserTyping> {
  const MqttUserTyping({
    required this.roomId,
    required this.userId,
    this.isTyping = true,
  });
  final String roomId;
  final String userId;
  final bool isTyping;

  @override
  String get topic => TopicBuilder.typing(roomId, userId);

  @override
  Stream<UserTyping> receive(Tuple2<String, String> message) async* {
    var payload = message.second.toString();
    var topic = message.first.split('/');
    var roomId = int.parse(topic[1]);
    var userId = topic[3];
    yield UserTyping(
      isTyping: payload == '1',
      roomId: roomId,
      userId: userId,
    );
  }

  @override
  String publish() {
    if (isTyping) return '1';
    return '0';
  }
}
