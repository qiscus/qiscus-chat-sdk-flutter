import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/room/room-model.dart';
import 'package:qiscus_chat_sdk/src/impls/room/room-from-json-impl.dart';

RTE<State<Iterable<QChatRoom>, QChatRoom>> updateChatRoomImpl({
  required int roomId,
  String? name,
  String? avatarUrl,
  Json? extras,
}) {
  return tryCR((dio) async {
    var req = UpdateRoomRequest(
      roomId: roomId.toString(),
      name: name,
      avatarUrl: avatarUrl,
      extras: extras,
    );
    var room = await req(dio);

    return State((rooms) {
      return Tuple2(
        room,
        [...rooms.where((it) => it.id != room.id), room],
      );
    });
  });
}

class UpdateRoomRequest extends IApiRequest<QChatRoom> {
  UpdateRoomRequest({
    required this.roomId,
    this.name,
    this.avatarUrl,
    this.extras,
  });

  final String roomId;
  final String? name;
  final String? avatarUrl;
  final Json? extras;

  @override
  String get url => 'update_room';

  @override
  IRequestMethod get method => IRequestMethod.post;

  @override
  Json get body => <String, dynamic>{
        'id': roomId,
        'name': name,
        'avatar_url': avatarUrl,
        'options': jsonEncode(extras),
      };

  @override
  QChatRoom format(Json json) {
    return roomFromJson((json['results'] as Map)['room'] as Json);
  }
}
