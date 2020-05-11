import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/participant.dart';
import 'package:retrofit/retrofit.dart';

import 'entity.dart';

part 'api.g.dart';

@RestApi(autoCastResponse: false)
abstract class RoomApi {
  factory RoomApi(Dio dio) = _RoomApi;

  @POST('get_or_create_room_with_target')
  Future<String> chatTarget(@Body() ChatTargetRequest request);

  @GET('get_room_by_id')
  Future<String> getRoomById(@Query('id') int roomId);

  @POST('add_room_participants')
  Future<String> addParticipant(@Body() ParticipantRequest request);

  @POST('remove_room_participants')
  Future<String> removeParticipant(@Body() ParticipantRequest request);

  @GET('room_participants')
  Future<String> getParticipants(@Body() GetParticipantsRequest request);

  @GET('user_rooms')
  Future<String> getAllRooms(@Body() GetAllRoomsRequest request);

  @POST('get_or_create_room_with_unique_id')
  Future<String> getOrCreateChannel(@Body() GetOrCreateChannelRequest request);

  @POST('create_room')
  Future<String> createGroup(@Body() CreateGroupRequest request);

  @DELETE('clear_room_messages')
  Future<String> clearMessages(
      @Query('room_channel_ids') List<String> uniqueIds);

  @POST('rooms_info')
  Future<String> getRoomInfo(@Body() GetRoomInfoRequest request);

  @GET('total_unread_count')
  Future<String> getTotalUnreadCount();

  @POST('update_room')
  Future<String> updateRoom(@Body() UpdateRoomRequest request);
}

@sealed
@immutable
@JsonSerializable()
class UpdateRoomRequest {
  const UpdateRoomRequest({
    @required this.roomId,
    this.name,
    this.avatarUrl,
    this.extras,
  });

  @JsonKey(name: 'id')
  final String roomId;
  @JsonKey(nullable: true)
  final String name;
  @JsonKey(name: 'avatar_url', nullable: true)
  final String avatarUrl;
  @JsonKey(nullable: true)
  final Map<String, dynamic> extras;

  Map<String, dynamic> toJson() => _$UpdateRoomRequestToJson(this);
}

@immutable
@JsonSerializable()
class GetRoomInfoRequest {
  const GetRoomInfoRequest({
    this.roomIds,
    this.uniqueIds,
    this.withParticipants,
    this.withRemoved,
    this.page,
  });
  @JsonKey(name: 'room_id', nullable: true)
  final List<String> roomIds;
  @JsonKey(name: 'room_unique_id', nullable: null)
  final List<String> uniqueIds;
  @JsonKey(name: 'show_participants', nullable: true)
  final bool withParticipants;
  @JsonKey(name: 'show_removed', nullable: true)
  final bool withRemoved;
  final int page;

  Map<String, dynamic> toJson() => _$GetRoomInfoRequestToJson(this);
}

@immutable
@JsonSerializable()
class CreateGroupRequest {
  const CreateGroupRequest({
    @required this.name,
    @required this.userIds,
    this.avatarUrl,
    this.extras,
  });
  final String name;
  @JsonKey(name: 'participants')
  final List<String> userIds;
  @JsonKey(name: 'avatar_url')
  final String avatarUrl;
  final Map<String, dynamic> extras;

  Map<String, dynamic> toJson() => _$CreateGroupRequestToJson(this);
}

@immutable
@JsonSerializable()
class GetOrCreateChannelRequest {
  const GetOrCreateChannelRequest({
    @required this.uniqueId,
    this.name,
    this.avatarUrl,
    this.options,
  });

  @JsonKey(name: 'unique_id')
  final String uniqueId;
  final String name;
  @JsonKey(name: 'avatar_url')
  final String avatarUrl;
  final Map<String, dynamic> options;

  Map<String, dynamic> toJson() => _$GetOrCreateChannelRequestToJson(this);
}

@immutable
@JsonSerializable()
class GetParticipantsRequest {
  const GetParticipantsRequest(
    this.roomUniqueId, [
    this.page,
    this.limit,
    this.sorting,
  ]);

  @JsonKey(name: 'room_unique_id')
  final String roomUniqueId;
  @JsonKey(nullable: true)
  final int page;
  @JsonKey(nullable: true)
  final int limit;
  @JsonKey(nullable: true)
  final String sorting;

  Map<String, dynamic> toJson() => _$GetParticipantsRequestToJson(this);
}

@immutable
@JsonSerializable()
class ChatTargetRequest {
  const ChatTargetRequest(this.emails, [this.extras]);

  final List<String> emails;

  @JsonKey(nullable: true)
  final Map<String, dynamic> extras;

  Map<String, dynamic> toJson() => _$ChatTargetRequestToJson(this);
}

@sealed
@immutable
class AddParticipantResponse {
  const AddParticipantResponse(this.roomId, this.participants);

  final int roomId;
  final List<Participant> participants;
}

class RemoveParticipantResponse {
  const RemoveParticipantResponse(this.roomId, this.participantIds);

  final int roomId;
  final List<String> participantIds;
}

class GetParticipantsResponse {
  const GetParticipantsResponse(this.uniqueId, this.participants);

  final String uniqueId;
  final List<Participant> participants;
}

class GetAllRoomsResponse {
  const GetAllRoomsResponse(this.rooms);

  final List<ChatRoom> rooms;
}

@immutable
@JsonSerializable()
class GetAllRoomsRequest {
  const GetAllRoomsRequest({
    this.withParticipants,
    this.withEmptyRoom,
    this.withRemovedRoom,
    this.limit,
    this.page,
  });

  @JsonKey(name: 'show_participants', nullable: true)
  final bool withParticipants;
  @JsonKey(name: 'show_empty', nullable: true)
  final bool withEmptyRoom;
  @JsonKey(name: 'show_removed', nullable: true)
  final bool withRemovedRoom;
  @JsonKey(nullable: true)
  final int limit;
  @JsonKey(nullable: true)
  final int page;

  Map<String, dynamic> toJson() => _$GetAllRoomsRequestToJson(this);
}

@sealed
@immutable
@JsonSerializable()
class ParticipantRequest {
  const ParticipantRequest(this.roomId, this.participantIds);

  @JsonKey(name: 'room_id')
  final int roomId;
  @JsonKey(name: 'emails')
  final List<String> participantIds;

  Map<String, dynamic> toJson() => _$ParticipantRequestToJson(this);
}
