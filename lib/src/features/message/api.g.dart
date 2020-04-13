// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateStatusRequest _$UpdateStatusRequestFromJson(Map<String, dynamic> json) {
  return UpdateStatusRequest(
    roomId: json['room_id'] as String,
    lastReadId: json['last_comment_read_id'] as String ?? 0,
    lastDeliveredId: json['last_comment_received_id'] as String ?? 0,
  );
}

Map<String, dynamic> _$UpdateStatusRequestToJson(
        UpdateStatusRequest instance) =>
    <String, dynamic>{
      'room_id': instance.roomId,
      'last_comment_read_id': instance.lastReadId,
      'last_comment_received_id': instance.lastDeliveredId,
    };

PostCommentRequest _$PostCommentRequestFromJson(Map<String, dynamic> json) {
  return PostCommentRequest(
    roomId: json['topic_id'] as String,
    text: json['comment'] as String,
    type: json['type'] as String,
    uniqueId: json['unique_temp_id'] as String,
    payload: json['payload'] as Map<String, dynamic>,
    extras: json['extras'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$PostCommentRequestToJson(PostCommentRequest instance) =>
    <String, dynamic>{
      'topic_id': instance.roomId,
      'comment': instance.text,
      'type': instance.type,
      'unique_temp_id': instance.uniqueId,
      'payload': instance.payload,
      'extras': instance.extras,
    };

ChatTargetRequest _$ChatTargetRequestFromJson(Map<String, dynamic> json) {
  return ChatTargetRequest(
    (json['emails'] as List)?.map((e) => e as String)?.toList(),
    json['extras'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$ChatTargetRequestToJson(ChatTargetRequest instance) =>
    <String, dynamic>{
      'emails': instance.emails,
      'extras': instance.extras,
    };

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _MessageApi implements MessageApi {
  _MessageApi(this._dio, {this.baseUrl}) {
    ArgumentError.checkNotNull(_dio, '_dio');
  }

  final Dio _dio;

  String baseUrl;

  @override
  loadComments(roomId, {lastMessageId, after = false, limit = 20}) async {
    ArgumentError.checkNotNull(roomId, 'roomId');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      'topic_id': roomId,
      'last_comment_id': lastMessageId,
      'after': after,
      'limit': limit
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    final Response<String> _result = await _dio.request('load_comments',
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
  submitComment(request) async {
    ArgumentError.checkNotNull(request, 'request');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request?.toJson() ?? <String, dynamic>{});
    final Response<String> _result = await _dio.request('post_comment',
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
  updateStatus(request) async {
    ArgumentError.checkNotNull(request, 'request');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request?.toJson() ?? <String, dynamic>{});
    final Response<String> _result = await _dio.request('update_comment_status',
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
  deleteMessages(uniqueIds, [isHardDelete = true, isForEveryOne = true]) async {
    ArgumentError.checkNotNull(uniqueIds, 'uniqueIds');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      'unique_ids': uniqueIds,
      'is_hard_delete': isHardDelete,
      'is_delete_for_everyone': isForEveryOne
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    final Response<String> _result = await _dio.request('delete_messages',
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
}
