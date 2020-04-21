// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: argument_type_not_assignable, implicit_dynamic_parameter, unused_element

part of 'api.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _SyncApi implements SyncApi {
  _SyncApi(this._dio, {this.baseUrl}) {
    ArgumentError.checkNotNull(_dio, '_dio');
  }

  final Dio _dio;

  String baseUrl;

  @override
  synchronize(lastCommentId) async {
    ArgumentError.checkNotNull(lastCommentId, 'lastCommentId');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      'last_received_comment_id': lastCommentId
    };
    final _data = <String, dynamic>{};
    final Response<Map<String, dynamic>> _result = await _dio.request('sync',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = SynchronizeResponse.fromJson(_result.data);
    return Future.value(value);
  }

  @override
  synchronizeEvent(eventId) async {
    ArgumentError.checkNotNull(eventId, 'eventId');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{'start_event_id': eventId};
    final _data = <String, dynamic>{};
    final Response<Map<String, dynamic>> _result = await _dio.request(
        'sync_event',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = SynchronizeEventResponse.fromJson(_result.data);
    return Future.value(value);
  }
}
