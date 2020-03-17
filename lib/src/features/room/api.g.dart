// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
}
