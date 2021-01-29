part of qiscus_chat_sdk.realtime;

class MqttRoomCleared extends IMqttReceive<int> {
  const MqttRoomCleared({@required this.token});

  final String token;

  @override
  String get topic => TopicBuilder.notification(token);

  @override
  Stream<int> receive(Tuple2<String, String> event) async* {
    var json = jsonDecode(event.payload) as Map<String, dynamic>;
    var actionType = json['action_topic'] as String;
    var payload = json['payload'] as Map<String, dynamic>;

    if (actionType == 'clear_room') {
      var rooms = (payload['data']['deleted_rooms'] as List)
          .cast<Map<String, dynamic>>();
      for (var room in rooms) {
        yield room['id'] as int;
      }
    }
  }
}
