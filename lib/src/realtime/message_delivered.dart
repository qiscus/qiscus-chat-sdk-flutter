part of qiscus_chat_sdk.realtime;

class MqttMessageDelivered extends IMqttReceive<Message> {
  const MqttMessageDelivered({@required this.roomId});
  final String roomId;

  @override
  String get topic => TopicBuilder.messageDelivered(roomId);

  @override
  Stream<Message> receive(Tuple2<String, String> data) async* {
    var payload = data.payload.split(':');
    var commentId = optionOf(payload[0]).map((it) => int.parse(it));
    var commentUniqueId = optionOf(payload[1]);
    yield Message(
      id: commentId,
      uniqueId: commentUniqueId,
      chatRoomId: some(roomId).map((it) => int.parse(it)),
    );
  }
}
