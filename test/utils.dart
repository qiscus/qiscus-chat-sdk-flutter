import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:mockito/mockito.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/realtime.dart';

class MockDio extends Mock implements Dio {}
class MockInterval extends Mock implements Interval {}
class MockLogger extends Mock implements Logger {}

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

  static Future<Response<Map<String, dynamic>>> makeResponse(
      Map<String, dynamic> json) {
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

List<MqttReceivedMessage<MqttMessage>> makeMqttMessage(String topic, String payload) {
  var it = MqttClientPayloadBuilder()..addString(payload);
  var message = MqttPublishMessage()..publishData(it.payload);
  return [MqttReceivedMessage<MqttMessage>(topic, message)];
}

extension Xx on List<MqttReceivedMessage<MqttMessage>> {
  void call(MqttClient mqtt) {
    when(mqtt.updates).thenAnswer((_) => Stream.value(this));
  }
}
