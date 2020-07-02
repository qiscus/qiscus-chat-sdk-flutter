// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: argument_type_not_assignable, implicit_dynamic_parameter, unused_element

part of 'api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateRoomRequest _$UpdateRoomRequestFromJson(Map<String, dynamic> json) {
  return UpdateRoomRequest(
    roomId: json['id'] as String,
    name: json['name'] as String,
    avatarUrl: json['avatar_url'] as String,
    extras: json['options'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$UpdateRoomRequestToJson(UpdateRoomRequest instance) =>
    <String, dynamic>{
      'id': instance.roomId,
      'name': instance.name,
      'avatar_url': instance.avatarUrl,
      'options': instance.extras,
    };

GetRoomInfoRequest _$GetRoomInfoRequestFromJson(Map<String, dynamic> json) {
  return GetRoomInfoRequest(
    roomIds: (json['room_id'] as List)?.map((e) => e as String)?.toList(),
    uniqueIds:
        (json['room_unique_id'] as List)?.map((e) => e as String)?.toList(),
    withParticipants: json['show_participants'] as bool,
    withRemoved: json['show_removed'] as bool,
    page: json['page'] as int,
  );
}

Map<String, dynamic> _$GetRoomInfoRequestToJson(GetRoomInfoRequest instance) =>
    <String, dynamic>{
      'room_id': instance.roomIds,
      'room_unique_id': instance.uniqueIds,
      'show_participants': instance.withParticipants,
      'show_removed': instance.withRemoved,
      'page': instance.page,
    };

CreateGroupRequest _$CreateGroupRequestFromJson(Map<String, dynamic> json) {
  return CreateGroupRequest(
    name: json['name'] as String,
    userIds: (json['participants'] as List)?.map((e) => e as String)?.toList(),
    avatarUrl: json['avatar_url'] as String,
    extras: json['options'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$CreateGroupRequestToJson(CreateGroupRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'participants': instance.userIds,
      'avatar_url': instance.avatarUrl,
      'options': instance.extras,
    };

GetOrCreateChannelRequest _$GetOrCreateChannelRequestFromJson(
    Map<String, dynamic> json) {
  return GetOrCreateChannelRequest(
    uniqueId: json['unique_id'] as String,
    name: json['name'] as String,
    avatarUrl: json['avatar_url'] as String,
    options: json['options'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$GetOrCreateChannelRequestToJson(
        GetOrCreateChannelRequest instance) =>
    <String, dynamic>{
      'unique_id': instance.uniqueId,
      'name': instance.name,
      'avatar_url': instance.avatarUrl,
      'options': instance.options,
    };

GetParticipantsRequest _$GetParticipantsRequestFromJson(
    Map<String, dynamic> json) {
  return GetParticipantsRequest(
    json['room_unique_id'] as String,
    json['page'] as int,
    json['limit'] as int,
    json['sorting'] as String,
  );
}

Map<String, dynamic> _$GetParticipantsRequestToJson(
        GetParticipantsRequest instance) =>
    <String, dynamic>{
      'room_unique_id': instance.roomUniqueId,
      'page': instance.page,
      'limit': instance.limit,
      'sorting': instance.sorting,
    };

ChatTargetRequest _$ChatTargetRequestFromJson(Map<String, dynamic> json) {
  return ChatTargetRequest(
    (json['emails'] as List)?.map((e) => e as String)?.toList(),
    json['options'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$ChatTargetRequestToJson(ChatTargetRequest instance) =>
    <String, dynamic>{
      'emails': instance.emails,
      'options': instance.extras,
    };

GetAllRoomsRequest _$GetAllRoomsRequestFromJson(Map<String, dynamic> json) {
  return GetAllRoomsRequest(
    withParticipants: json['show_participants'] as bool,
    withEmptyRoom: json['show_empty'] as bool,
    withRemovedRoom: json['show_removed'] as bool,
    limit: json['limit'] as int,
    page: json['page'] as int,
  );
}

Map<String, dynamic> _$GetAllRoomsRequestToJson(GetAllRoomsRequest instance) =>
    <String, dynamic>{
      'show_participants': instance.withParticipants,
      'show_empty': instance.withEmptyRoom,
      'show_removed': instance.withRemovedRoom,
      'limit': instance.limit,
      'page': instance.page,
    };

ParticipantRequest _$ParticipantRequestFromJson(Map<String, dynamic> json) {
  return ParticipantRequest(
    json['room_id'] as String,
    (json['emails'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$ParticipantRequestToJson(ParticipantRequest instance) =>
    <String, dynamic>{
      'room_id': instance.roomId,
      'emails': instance.participantIds,
    };

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _RoomApi implements RoomApi {
  _RoomApi(this._dio, {this.baseUrl}) {
    ArgumentError.checkNotNull(_dio, '_dio');
  }

  final Dio _dio;

  String baseUrl;

  @override
  chatTarget(request) async {
    ArgumentError.checkNotNull(request, 'request');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request?.toJson() ?? <String, dynamic>{});
    final Response<String> _result = await _dio.request(
        'get_or_create_room_with_target',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = _result.data;
    return Future.value(value);
  }

  @override
  getRoomById(roomId) async {
    ArgumentError.checkNotNull(roomId, 'roomId');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{'id': roomId};
    final _data = <String, dynamic>{};
    final Response<String> _result = await _dio.request('get_room_by_id',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = _result.data;
    return Future.value(value);
  }

  @override
  addParticipant(request) async {
    ArgumentError.checkNotNull(request, 'request');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request?.toJson() ?? <String, dynamic>{});
    final Response<String> _result = await _dio.request('add_room_participants',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = _result.data;
    return Future.value(value);
  }

  @override
  removeParticipant(request) async {
    ArgumentError.checkNotNull(request, 'request');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request?.toJson() ?? <String, dynamic>{});
    final Response<String> _result = await _dio.request(
        'remove_room_participants',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = _result.data;
    return Future.value(value);
  }

  @override
  getParticipants(request) async {
    ArgumentError.checkNotNull(request, 'request');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request?.toJson() ?? <String, dynamic>{});
    final Response<String> _result = await _dio.request('room_participants',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = _result.data;
    return Future.value(value);
  }

  @override
  getAllRooms(request) async {
    ArgumentError.checkNotNull(request, 'request');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request?.toJson() ?? <String, dynamic>{});
    final Response<String> _result = await _dio.request('user_rooms',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = _result.data;
    return Future.value(value);
  }

  @override
  getOrCreateChannel(request) async {
    ArgumentError.checkNotNull(request, 'request');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request?.toJson() ?? <String, dynamic>{});
    final Response<String> _result = await _dio.request(
        'get_or_create_room_with_unique_id',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = _result.data;
    return Future.value(value);
  }

  @override
  createGroup(request) async {
    ArgumentError.checkNotNull(request, 'request');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request?.toJson() ?? <String, dynamic>{});
    final Response<String> _result = await _dio.request('create_room',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = _result.data;
    return Future.value(value);
  }

  @override
  clearMessages(uniqueIds) async {
    ArgumentError.checkNotNull(uniqueIds, 'uniqueIds');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{'room_channel_ids': uniqueIds};
    final _data = <String, dynamic>{};
    final Response<String> _result = await _dio.request('clear_room_messages',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'DELETE',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = _result.data;
    return Future.value(value);
  }

  @override
  getRoomInfo(request) async {
    ArgumentError.checkNotNull(request, 'request');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request?.toJson() ?? <String, dynamic>{});
    final Response<String> _result = await _dio.request('rooms_info',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = _result.data;
    return Future.value(value);
  }

  @override
  getTotalUnreadCount() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final Response<String> _result = await _dio.request('total_unread_count',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = _result.data;
    return Future.value(value);
  }

  @override
  updateRoom(request) async {
    ArgumentError.checkNotNull(request, 'request');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request?.toJson() ?? <String, dynamic>{});
    final Response<String> _result = await _dio.request('update_room',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = _result.data;
    return Future.value(value);
  }
}
