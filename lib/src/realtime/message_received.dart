part of qiscus_chat_sdk.realtime;

class MqttMessageReceived extends IMqttReceive<Message> {
  const MqttMessageReceived({@required this.token}) : super();
  final String token;

  @override
  String get topic => TopicBuilder.messageNew(token);

  @override
  Stream<Message> receive(Tuple2<String, String> data) async* {
    var message = jsonDecode(data.payload) as Map<String, dynamic>;
    yield Message.fromJson(message);
  }
}
