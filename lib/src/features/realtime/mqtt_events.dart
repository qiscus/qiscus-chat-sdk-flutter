part of qiscus_chat_sdk.usecase.realtime;

class MqttTypingEvent extends MqttEventHandler<bool, UserTyping> {
  const MqttTypingEvent({
    @required this.roomId,
    @required this.userId,
    this.isTyping,
  });

  // r/{roomId}/{roomId}/{userId}/t
  @override
  String get topic => 'r/$roomId/+/$userId/t';
  final String roomId;
  final String userId;
  final bool isTyping;

  @override
  publish() {
    if (isTyping != null && isTyping == true) return '1';
    return '0';
  }

  @override
  receive(message) async* {
    var payload = message.value2.toString();
    var topic = message.value1.split('/');
    var roomId = optionOf(topic[1]).map((it) => int.tryParse(it));
    var userId = optionOf(topic[3]);
    yield UserTyping(
      isTyping: payload == '1',
      roomId: roomId.toNullable(),
      userId: userId.toNullable(),
    );
  }
}

class MqttCustomEvent
    extends MqttEventHandler<Map<String, dynamic>, CustomEvent> {
  const MqttCustomEvent({
    @required this.roomId,
    this.payload,
  });

  @override
  publish() {
    return jsonEncode(payload);
  }

  @override
  receive(message) async* {
    var payload = message.value2.toString();
    var data = jsonDecode(payload) as Map<String, dynamic>;
    yield CustomEvent(
      roomId: roomId,
      payload: data,
    );
  }

  @override
  String get topic => TopicBuilder.customEvent(roomId);
  final int roomId;
  final Map<String, dynamic> payload;
}

class MqttPresenceEvent extends MqttEventHandler<UserPresence, UserPresence> {
  const MqttPresenceEvent({
    @required this.userId,
    this.isOnline,
    this.lastSeen,
  });
  @override
  String publish() {
    var payload = isOnline ? '1' : '0';
    var millis = lastSeen.millisecondsSinceEpoch;
    return '$payload:$millis';
  }

  @override
  receive(msg) async* {
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

  get topic => TopicBuilder.presence(userId);
  final String userId;
  final bool isOnline;
  final DateTime lastSeen;
}

class MqttMessageReceivedEvent extends MqttEventHandler<void, Message> {
  const MqttMessageReceivedEvent({
    @required this.token,
  });

  @override
  String publish() {
    return '';
  }

  @override
  receive(message) async* {
    var decode = (String str) => jsonDecode(str) as Map<String, dynamic>;
    var data = decode(message.payload.toString());
    yield Message.fromJson(data);
  }

  @override
  String get topic => TopicBuilder.messageNew(token);
  final String token;
}

class MqttMessageReadEvent extends MqttEventHandler<Message, Message> {
  const MqttMessageReadEvent({
    @required this.roomId,
    this.messageId,
  });
  @override
  String publish() {
    throw UnimplementedError();
  }

  @override
  Stream<Message> receive(msg) async* {
    var payload = msg.payload.toString().split(':');
    var commentId = optionOf(payload[0]).map((it) => int.parse(it));
    var commentUniqueId = optionOf(payload[1]);
    yield Message(
      id: commentId,
      uniqueId: commentUniqueId,
      chatRoomId: some(roomId).map((it) => int.parse(it)),
    );
  }

  @override
  String get topic => TopicBuilder.messageRead(roomId);
  final String roomId;
  final String messageId;
}
