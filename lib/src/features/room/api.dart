import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/participant.dart';
import 'package:retrofit/retrofit.dart';

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
}

@immutable
@JsonSerializable()
class GetParticipantsRequest {
  const GetParticipantsRequest(this.roomUniqueId,
      [this.page, this.limit, this.sorting]);

  @JsonKey(name: 'unique_id')
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

@sealed
@immutable
@JsonSerializable()
class ParticipantRequest {
  const ParticipantRequest(this.roomId, this.participantIds);

  final int roomId;
  final List<String> participantIds;

  Map<String, dynamic> toJson() => _$ParticipantRequestToJson(this);
}
