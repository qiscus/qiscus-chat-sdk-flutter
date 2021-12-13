import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/room/room-model.dart';

import 'room-from-json-impl.dart';

ReaderTaskEither<Dio, String, QChatRoom> createGroupChatImpl(
  String name,
  List<String> userIds, {
  String? avatarUrl,
  Json? extras,
}) {
  return Reader((Dio dio) {
    return TaskEither.tryCatch(() async {
      var req = CreateGroupRequest(
        name: name,
        userIds: userIds,
        avatarUrl: avatarUrl,
        extras: extras,
      );

      return req(dio);
    }, (e, _) => e.toString());
  });
}

class CreateGroupRequest extends IApiRequest<QChatRoom> {
  CreateGroupRequest({
    required this.name,
    required this.userIds,
    this.avatarUrl,
    this.extras,
  });

  final String name;
  final List<String> userIds;

  final String? avatarUrl;
  final Map<String, dynamic>? extras;

  @override
  String get url => 'create_room';

  @override
  IRequestMethod get method => IRequestMethod.post;

  @override
  Map<String, dynamic> get body => <String, dynamic>{
        'name': name,
        'participants': userIds,
        'avatar_url': avatarUrl,
        'options': extras == null ? null : jsonEncode(extras),
      };

  @override
  QChatRoom format(Map<String, dynamic> json) {
    return roomFromJson(json['results']['room'] as Map<String, dynamic>);
  }
}
