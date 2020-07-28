import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:mockito/mockito.dart';

class MockDio extends Mock implements Dio {}

extension DioX on Dio {

  Future<Response<Map<String, dynamic>>> requestJson(
    String path, {
    dynamic data,
    Map<String, dynamic> queryParameters,
    CancelToken cancelToken,
    Options options,
    void Function(int, int) onSendProgress,
    void Function(int, int) onReceiveProgress,
  }) {
    return request<Map<String, dynamic>>(
      path,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  static Future<Response<Map<String, dynamic>>> makeResponse(Map<String, dynamic> json) {
    return Future.value(Response(data: json));
  }
}

void makeTest(Dio dio, Map<String, dynamic> response) {
  when(dio.requestJson(
    any,
    data: anyNamed('data'),
    queryParameters: anyNamed('queryParameters'),
    options: anyNamed('options'),
  )).thenAnswer((_) {
    return DioX.makeResponse(response);
  });
}

class OptionsX extends Options with EquatableMixin {
  OptionsX({
    String method,
    int sendTimeout,
    int receiveTimeout,
    Map<String, dynamic> extra,
    Map<String, dynamic> headers,
    ResponseType responseType,
    String contentType,
    ValidateStatus validateStatus,
    bool receiveDataWhenStatusError,
    bool followRedirects,
    int maxRedirects,
    RequestEncoder requestEncoder,
    ResponseDecoder responseDecoder,
}) : super(
    method: method,
    sendTimeout: sendTimeout,
    receiveTimeout: receiveTimeout,
    extra: extra,
    headers: headers,
    responseType: responseType,
    contentType: contentType,
    validateStatus: validateStatus,
    receiveDataWhenStatusError: receiveDataWhenStatusError,
    followRedirects: followRedirects,
    maxRedirects: maxRedirects,
    requestEncoder: requestEncoder,
    responseDecoder: responseDecoder,
  );

  @override
  List<Object> get props => [method, headers, contentType];
}
