part of qiscus_chat_sdk.realtime;

class MqttMessageDeleted extends IMqttReceive<Tuple2<int, String>> {
  const MqttMessageDeleted({required this.token});
  final String token;

  @override
  String get topic => TopicBuilder.notification(token);

  @override
  Stream<Tuple2<int, String>> receive(Tuple2<String, String> event) async* {
    var json = jsonDecode(event.second) as Map<String, dynamic>;
    var actionType = json['action_topic'] as String;
    var payload = json['payload'] as Map<String, dynamic>;

    if (actionType == 'delete_message') {
      var mPayload = (payload['data']['deleted_messages'] as List)
          .cast<Map<String, dynamic>>();
      for (var m in mPayload) {
        var roomId = m['room_id'] as String;
        var uniqueIds = (m['message_unique_ids'] as List).cast<String>();
        for (var id in uniqueIds) {
          yield Tuple2(int.parse(roomId), id);
        }
      }
    }
  }
}
