import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:retrofit/retrofit.dart';

part 'api.g.dart';

@RestApi()
abstract class RoomApi {
  factory RoomApi(Dio dio) = _RoomApi;

  @POST('get_or_create_room_with_target', autoCastResponse: false)
  Future<String> chatTarget(@Body() ChatTargetRequest request);

  @GET('get_room_by_id', autoCastResponse: false)
  Future<String> getRoomById(@Query('id') int roomId);
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
