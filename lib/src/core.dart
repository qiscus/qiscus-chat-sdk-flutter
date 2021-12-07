library qiscus_chat_sdk.core;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:qiscus_chat_sdk/src/domain/message/message-model.dart';
import 'package:qiscus_chat_sdk/src/domain/room/room-model.dart';
import 'package:qiscus_chat_sdk/src/domain/user/user-model.dart';

import 'realtime/realtime.dart';

part 'core/api_request.dart';
part 'core/constants.dart';
part 'core/dio.dart';
part 'core/errors.dart';
part 'core/extension.dart';
part 'core/logger.dart';
part 'core/mqtt.dart';
part 'core/storage.dart';
part 'core/subscription_usecase.dart';
part 'core/typedefs.dart';
part 'core/usecases.dart';
part 'core/utils.dart';
part 'core/dio2curl.dart';

final reNewMessage = RegExp(r'^(.+)\/c$', caseSensitive: false);
final reNotification = '^(.+)\/n$';
final reTyping = RegExp(r'^r\/([\d]+)\/([\d]+)\/(.+)\/t$', caseSensitive: false);
final reDelivery = RegExp(r'^r\/([\d]+)\/([\d]+)\/(.+)\/d$', caseSensitive: false);
final reRead = RegExp(r'^r\/([\d]+)\/([\d]+)\/(.+)\/r$', caseSensitive: false);
final reOnlineStatus = RegExp(r'^u\/(.+)\/s$', caseSensitive: false);
final reChannelMessage = RegExp(r'^(.+)\/(.+)\/c$', caseSensitive: false);
final reMessageUpdated = RegExp(r'^(.+)\/update$', caseSensitive: false);

abstract class TopicBuilder {
  static String typing(String roomId, String userId) =>
      'r/$roomId/$roomId/$userId/t';

  static String presence(String userId) => 'u/$userId/s';

  static String messageDelivered(String roomId) => 'r/$roomId/+/+/d';

  static String notification(String token) => '$token/n';

  static String messageRead(String roomId) => 'r/$roomId/+/+/r';

  static String messageNew(String token) => '$token/c';
  static String messageUpdated(String token) => '$token/update';

  static String channelMessageNew(String appId, String channelId) =>
      '$appId/$channelId/c';

  static String customEvent(int roomId) => 'r/$roomId/$roomId/e';
}


TaskEither<String, T> tryCatch<T>(Future<T> Function() fn) {
  return TaskEither.tryCatch(fn, (e, _) => e.toString());
}

Reader<R, TaskEither<String, T>> tryCR<R, T>(Future<T> Function(R r) fn) {
  return Reader((r) {
    return tryCatch(() async {
      return fn(r);
    });
  });
}
