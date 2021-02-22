part of qiscus_chat_sdk.realtime;

class MqttMessageUpdated extends IMqttReceive<Message> {
  const MqttMessageUpdated({@required this.token});
  final String token;

  @override
  String get topic => TopicBuilder.messageUpdated(token);

  @override
  Stream<Message> receive(Tuple2<String, String> data) async* {
    var message = jsonDecode(data.second) as Map<String, dynamic>;
    yield Message.fromJson(message);
  }
}
