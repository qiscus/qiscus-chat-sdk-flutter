part of qiscus_chat_sdk.realtime;

class MqttNotification extends IMqttReceive<Notification> {
  const MqttNotification({@required this.token});
  final String token;

  @override
  String get topic => TopicBuilder.notification(token);

  @override
  Stream<Notification> receive(Tuple2<String, String> event) async* {
    var json = jsonDecode(event.payload) as Map<String, dynamic>;
    var actionType = json['action_topic'] as String;
    var payload = json['payload'] as Map<String, dynamic>;

    // Message deleted
    if (actionType == 'delete_message') {
      var p = (payload['data']['deleted_messages'] as List)
          .cast<Map<String, dynamic>>();
      for (var data in p) {
        var roomId = data['room_id'] as String;
        var uniqueIds = (data['message_unique_ids'] as List).cast<String>();
        for (var id in uniqueIds) {
          yield Notification.message_deleted(
            roomId: int.parse(roomId),
            messageUniqueId: id,
          );
        }
      }
    }

    // Room cleared
    if (actionType == 'clear_room') {
      var rooms = (payload['data']['deleted_rooms'] as List)
          .cast<Map<String, dynamic>>();
      for (var room in rooms) {
        yield Notification.room_cleared(roomId: room['id'] as int);
      }
    }
  }
}
