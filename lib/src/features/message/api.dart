import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:retrofit/retrofit.dart';

part 'api.g.dart';

@RestApi(autoCastResponse: false)
abstract class MessageApi {
  factory MessageApi(Dio dio) = _MessageApi;

  @GET('load_comments')
  Future<String> loadComments(
    @Query('topic_id') int roomId,
    @Query('last_comment_id') int lastMessageId, {
    @Query('after') bool after = false,
    @Query('limit') int limit = 20,
  });

  @POST('post_comment')
  Future<String> submitComment(@Body() PostCommentRequest request);

  @POST('update_comment_status')
  Future<String> updateStatus(@Body() UpdateStatusRequest request);
}

@JsonSerializable()
class UpdateStatusRequest {
  const UpdateStatusRequest({
    this.roomId,
    this.lastReadId = 0,
    this.lastDeliveredId = 0,
  });

  @JsonKey(name: 'room_id')
  final int roomId;

  @JsonKey(name: 'last_comment_read_id', defaultValue: 0)
  final int lastReadId;
  @JsonKey(name: 'last_comment_received_id', defaultValue: 0)
  final int lastDeliveredId;
}

@JsonSerializable()
class PostCommentRequest {
  @JsonKey(name: 'topic_id')
  final String roomId;
  @JsonKey(name: 'comment')
  final String text;
  final String type;
  @JsonKey(name: 'unique_temp_id')
  final String uniqueId;
  final Map<String, dynamic> payload, extras;

  const PostCommentRequest({
    @required this.roomId,
    @required this.text,
    @required this.type,
    @required this.uniqueId,
    this.payload,
    this.extras,
  });

  Map<String, dynamic> toJson() => _$PostCommentRequestToJson(this);
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
