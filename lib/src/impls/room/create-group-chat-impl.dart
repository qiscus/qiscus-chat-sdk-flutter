import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/room/room-model.dart';

import 'room-from-json-impl.dart';

Reader<Dio, TaskEither<QError, QChatRoom>> createGroupChatImpl(
  String name,
  List<String> userIds, {
  String? avatarUrl,
  Json? extras,
}) {
  return tryCR((Dio dio) async {
    var req = CreateGroupRequest(
      name: name,
      userIds: userIds,
      avatarUrl: avatarUrl,
      extras: extras,
    );

    return req.call(dio);
  });
}

class CreateGroupRequest extends IApiRequest<QChatRoom> {
  const CreateGroupRequest({
    required this.name,
    required this.userIds,
    required this.avatarUrl,
    required this.extras,
  });

  final String name;
  final List<String> userIds;

  final String? avatarUrl;
  final Json? extras;

  @override
  String get url => 'create_room';

  @override
  IRequestMethod get method => IRequestMethod.post;

  @override
  Json get body => <String, dynamic>{
        'name': name,
        'participants': userIds,
        'avatar_url': avatarUrl,
        'options': extras == null ? null : jsonEncode(extras),
      };

  @override
  QChatRoom format(Json json) {
    return roomFromJson((json['results'] as Map?)?['room'] as Json);
  }
}
