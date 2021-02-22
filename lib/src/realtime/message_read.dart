part of qiscus_chat_sdk.realtime;

class MqttMessageRead extends IMqttReceive<Message> {
  const MqttMessageRead({@required this.roomId});
  final String roomId;

  @override
  String get topic => TopicBuilder.messageRead(roomId);
  @override
  Stream<Message> receive(Tuple2<String, String> data) async* {
    var payload = data.second.toString().split(':');
    var commentId = Option.of(payload[0]).map((it) => int.parse(it));
    var commentUniqueId = Option.of(payload[1]);
    yield Message(
      id: commentId,
      uniqueId: commentUniqueId,
      chatRoomId: Option.some(roomId).map((it) => int.parse(it)),
    );
  }
}
