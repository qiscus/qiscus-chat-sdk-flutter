part of qiscus_chat_sdk.realtime;

class MqttUserPresence
    implements IMqttReceive<UserPresence>, IMqttPublish<UserPresence> {
  const MqttUserPresence({
    @required this.userId,
    this.lastSeen,
    this.isOnline,
  });
  final String userId;
  final DateTime lastSeen;
  final bool isOnline;

  @override
  String get topic => TopicBuilder.presence(userId);

  @override
  Stream<UserPresence> receive(Tuple2<String, String> msg) async* {
    var payload = msg.value2.toString().split(':');
    var userId_ = msg.value1.split('/')[1];
    var onlineStatus = optionOf(payload[0]) //
        .map((str) => str == '1' ? true : false);
    var timestamp = optionOf(payload[1])
        .map((str) => DateTime.fromMillisecondsSinceEpoch(int.parse(str)));
    yield UserPresence(
      userId: userId_,
      isOnline: onlineStatus.unwrap('onlineStatus are null'),
      lastSeen: timestamp.unwrap('lastSeen are null'),
    );
  }

  @override
  String publish() {
    var payload = isOnline ? '1' : '0';
    var millis = lastSeen.millisecondsSinceEpoch;
    return '$payload:$millis';
  }
}
