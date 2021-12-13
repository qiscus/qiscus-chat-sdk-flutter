import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';

var setupImpl = (
  String appId, {
  String? baseUrl,
  String? brokerUrl,
  String? brokerLbUrl,
  int? syncInterval,
  int? syncIntervalWhenConnected,
}) {

  return Reader((Dio dio) {
    return tryCatch(() async {});
  });
};
