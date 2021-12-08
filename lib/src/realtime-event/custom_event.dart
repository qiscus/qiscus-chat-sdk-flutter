part of qiscus_chat_sdk.realtime;


class MqttCustomEvent
    implements IMqttReceive<CustomEvent>, IMqttPublish<CustomEvent> {
  const MqttCustomEvent({required this.roomId, this.payload});

  final int roomId;
  final Map<String, dynamic>? payload;

  @override
  String get topic => TopicBuilder.customEvent(roomId);

  @override
  String publish() {
    return jsonEncode(payload);
  }

  @override
  Stream<CustomEvent> receive(Tuple2<String, String> event) async* {
    var payload = event.second.toString();
    var data = jsonDecode(payload) as Map<String, dynamic>;
    yield CustomEvent(
      roomId: roomId,
      payload: data,
    );
  }
}
