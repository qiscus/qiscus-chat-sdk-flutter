part of qiscus_chat_sdk.usecase.room;

class RoomFormatter {
  Tuple2<ChatRoom, Iterable<Message>> fromId(Map<String, dynamic> json) {
    var results = json['results'] as Map<String, dynamic>;
    var room = ChatRoom.fromJson(results['room'] as Map<String, dynamic>);
    var comments =
        (results['comments'] as List).cast<Map<String, dynamic>>().map((it) {
      return Message.fromJson(it);
    }).toList();
    return Tuple2(room, comments);
  }

  ChatRoom fromChatUser(Map<String, dynamic> json) {
    return ChatRoom.fromJson(json);
  }

  Iterable<Participant> fromAddParticipant(Map<String, dynamic> json) {
    var _participants = (json['results']['participants_added'] as List)
        .cast<Map<String, dynamic>>();
    var participants = _participants.map((json) => Participant.fromJson(json));
    return participants;
  }
}
