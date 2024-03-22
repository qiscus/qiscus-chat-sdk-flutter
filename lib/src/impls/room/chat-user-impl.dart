import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/room/room-model.dart';
import 'package:qiscus_chat_sdk/src/impls/room/room-from-json-impl.dart';

ReaderTaskEither<Dio, QError, QChatRoom> chatUserImpl(String userId,
    [Json? extras]) {
  return Reader((Dio dio) {
    return tryCatch(() async {
      var req = ChatTargetRequest(
        userId: userId,
        extras: extras,
      );
      return req(dio);
    });
  });
}

class ChatTargetRequest extends IApiRequest<QChatRoom> {
  const ChatTargetRequest({
    required this.userId,
    required this.extras,
  });

  final String userId;
  final Json? extras;

  @override
  String get url => 'get_or_create_room_with_target';

  @override
  IRequestMethod get method => IRequestMethod.post;

  @override
  Json get body => <String, dynamic>{
        'emails': [userId],
        'options': jsonEncode(extras),
      };

  @override
  QChatRoom format(Json json) {
    return roomFromJson((json['results'] as Map?)?['room'] as Json);
  }
}
