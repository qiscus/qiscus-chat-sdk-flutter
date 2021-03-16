part of qiscus_chat_sdk.usecase.room;

class ChatTargetRequest extends IApiRequest<ChatRoom> {
  ChatTargetRequest({
    @required this.userId,
    this.extras,
  });

  final String userId;
  final Map<String, dynamic> extras;

  @override
  String get url => 'get_or_create_room_with_target';

  @override
  IRequestMethod get method => IRequestMethod.post;

  @override
  Map<String, dynamic> get body => <String, dynamic>{
        'emails': [userId],
        'options': jsonEncode(extras),
      };

  @override
  ChatRoom format(Map<String, dynamic> json) {
    return ChatRoom.fromJson(json['results']['room'] as Map<String, dynamic>);
  }
}

class GetRoomByIdRequest extends IApiRequest<Tuple2<ChatRoom, List<Message>>> {
  GetRoomByIdRequest({
    @required this.roomId,
  });

  final int roomId;

  @override
  String get url => 'get_room_by_id';

  @override
  IRequestMethod get method => IRequestMethod.get;

  @override
  Map<String, dynamic> get params => <String, dynamic>{'id': roomId};

  @override
  Tuple2<ChatRoom, List<Message>> format(Map<String, dynamic> json) {
    var results = json['results'] as Map<String, dynamic>;
    var room = ChatRoom.fromJson(results['room'] as Map<String, dynamic>);
    var messages = (results['comments'] as List) //
        .cast<Map<String, dynamic>>()
        .map((it) => Message.fromJson(it))
        .toList();

    return Tuple2(room, messages);
  }
}

class AddParticipantRequest extends IApiRequest<List<Participant>> {
  AddParticipantRequest({
    @required this.roomId,
    @required this.userIds,
  });

  final int roomId;
  final List<String> userIds;

  @override
  String get url => 'add_room_participants';

  @override
  IRequestMethod get method => IRequestMethod.post;

  @override
  Map<String, dynamic> get body => <String, dynamic>{
        'room_id': roomId.toString(),
        'emails': userIds,
      };

  @override
  List<Participant> format(Map<String, dynamic> json) {
    var _participants = (json['results']['participants_added'] as List)
        .cast<Map<String, dynamic>>();
    var participants = _participants //
        .map((json) => Participant.fromJson(json))
        .toList();
    return participants;
  }
}

class RemoveParticipantRequest extends IApiRequest<List<String>> {
  RemoveParticipantRequest({
    @required this.roomId,
    @required this.userIds,
  });

  final int roomId;
  final List<String> userIds;

  @override
  String get url => 'remove_room_participants';

  @override
  IRequestMethod get method => IRequestMethod.post;

  @override
  Map<String, dynamic> get body => <String, dynamic>{
        'room_id': roomId.toString(),
        'emails': userIds,
      };

  @override
  List<String> format(Map<String, dynamic> json) {
    var ids = (json['results']['participants_removed'] as List) //
        .cast<String>();

    return ids;
  }
}

class GetParticipantRequest extends IApiRequest<List<Participant>> {
  GetParticipantRequest({
    @required this.roomUniqueId,
    this.page,
    this.limit,
    this.sorting,
  });

  final String roomUniqueId;
  final int page;
  final int limit;
  final String sorting;

  @override
  String get url => 'room_participants';

  @override
  IRequestMethod get method => IRequestMethod.get;

  @override
  Map<String, dynamic> get params => <String, dynamic>{
        'room_unique_id': roomUniqueId,
        'page': page,
        'limit': limit,
        'sorting': sorting,
      };

  @override
  List<Participant> format(Map<String, dynamic> json) {
    var participants_ = (json['results']['participants'] as List) //
        .cast<Map<String, dynamic>>();
    var participants = participants_ //
        .map((json) => Participant.fromJson(json))
        .toList();
    return participants;
  }
}

class GetAllRoomRequest extends IApiRequest<List<ChatRoom>> {
  GetAllRoomRequest({
    this.withParticipants,
    this.withEmptyRoom,
    this.withRemovedRoom,
    this.limit,
    this.page,
  });

  final bool withParticipants;
  final bool withEmptyRoom;
  final bool withRemovedRoom;
  final int limit;
  final int page;

  @override
  String get url => 'user_rooms';

  @override
  IRequestMethod get method => IRequestMethod.get;

  @override
  Map<String, dynamic> get params => <String, dynamic>{
        'show_participants': withParticipants,
        'show_empty': withEmptyRoom,
        'show_removed': withRemovedRoom,
        'limit': limit,
        'page': page,
      };

  @override
  List<ChatRoom> format(Map<String, dynamic> json) {
    var rooms_ = (json['results']['rooms_info'] as List) //
        .cast<Map<String, dynamic>>();
    var rooms = rooms_.map((json) => ChatRoom.fromJson(json)).toList();
    return rooms;
  }
}

class GetOrCreateChannelRequest extends IApiRequest<ChatRoom> {
  GetOrCreateChannelRequest({
    @required this.uniqueId,
    this.name,
    this.avatarUrl,
    this.extras,
  });

  final String uniqueId;
  final String name;
  final String avatarUrl;
  final Map<String, dynamic> extras;

  @override
  String get url => 'get_or_create_room_with_unique_id';

  @override
  IRequestMethod get method => IRequestMethod.post;

  @override
  Map<String, dynamic> get body => <String, dynamic>{
        'unique_id': uniqueId,
        'name': name,
        'avatar_url': avatarUrl,
        'options': extras != null ? jsonEncode(extras) : null,
      };

  @override
  ChatRoom format(Map<String, dynamic> json) {
    return ChatRoom.fromJson(json['results']['room'] as Map<String, dynamic>);
  }
}

class CreateGroupRequest extends IApiRequest<ChatRoom> {
  CreateGroupRequest({
    @required this.name,
    @required this.userIds,
    this.avatarUrl,
    this.extras,
  });

  final String name;
  final List<String> userIds;

  final String avatarUrl;
  final Map<String, dynamic> extras;

  @override
  String get url => 'create_room';

  @override
  IRequestMethod get method => IRequestMethod.post;

  @override
  Map<String, dynamic> get body => <String, dynamic>{
        'name': name,
        'participants': userIds,
        'avatar_url': avatarUrl,
        'options': extras == null ? null : jsonEncode(extras),
      };

  @override
  ChatRoom format(Map<String, dynamic> json) {
    return ChatRoom.fromJson(json['results']['room'] as Map<String, dynamic>);
  }
}

class ClearMessagesRequest extends IApiRequest<void> {
  ClearMessagesRequest({
    @required this.roomUniqueIds,
  });

  final List<String> roomUniqueIds;

  @override
  String get url => 'clear_room_messages';

  @override
  IRequestMethod get method => IRequestMethod.delete;

  @override
  Map<String, dynamic> get params => <String, dynamic>{
        'room_channel_ids': roomUniqueIds,
      };

  @override
  void format(_) => null;
}

class GetRoomInfoRequest extends IApiRequest<List<ChatRoom>> {
  GetRoomInfoRequest({
    this.roomIds,
    this.uniqueIds,
    this.withParticipants,
    this.withRemoved,
    this.page,
  });

  final List<int> roomIds;
  final List<String> uniqueIds;
  final bool withParticipants;
  final bool withRemoved;
  final int page;

  @override
  String get url => 'rooms_info';

  @override
  IRequestMethod get method => IRequestMethod.post;

  @override
  Map<String, dynamic> get body => <String, dynamic>{
        'room_id': roomIds.map((e) => e.toString()).toList(),
        'room_unique_id': uniqueIds,
        'show_participants': withParticipants,
        'show_removed': withRemoved,
        'page': page,
      };

  @override
  List<ChatRoom> format(Map<String, dynamic> json) {
    var roomsInfo = json['results']['rooms_info'] as List;
    return roomsInfo
        .cast<Map<String, dynamic>>()
        .map((json) => ChatRoom.fromJson(json))
        .toList();
  }
}

class GetTotalUnreadCountRequest extends IApiRequest<int> {
  @override
  String get url => 'total_unread_count';

  @override
  IRequestMethod get method => IRequestMethod.get;

  @override
  int format(Map<String, dynamic> json) {
    return json['results']['total_unread_count'] as int;
  }
}

class UpdateRoomRequest extends IApiRequest<ChatRoom> {
  UpdateRoomRequest({
    @required this.roomId,
    this.name,
    this.avatarUrl,
    this.extras,
  });

  final String roomId;
  final String name;
  final String avatarUrl;
  final Map<String, dynamic> extras;

  @override
  String get url => 'update_room';

  @override
  IRequestMethod get method => IRequestMethod.post;

  @override
  Map<String, dynamic> get body => <String, dynamic>{
        'id': roomId,
        'name': name,
        'avatar_url': avatarUrl,
        'options': jsonEncode(extras),
      };

  @override
  ChatRoom format(Map<String, dynamic> json) {
    return ChatRoom.fromJson(json['results']['room'] as Map<String, dynamic>);
  }
}
