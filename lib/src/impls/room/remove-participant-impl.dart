import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';

RTE<Iterable<String>> removeParticipantImpl({
  required int roomId,
  required Iterable<String> userIds,
}) {
  return Reader((dio) {
    return tryCatch(() async {
      var req = RemoveParticipantRequest(roomId: roomId, userIds: userIds);
      return req(dio);
    });
  });
}

class RemoveParticipantRequest extends IApiRequest<Iterable<String>> {
  RemoveParticipantRequest({
    required this.roomId,
    required this.userIds,
  });

  final int roomId;
  final Iterable<String> userIds;

  @override
  String get url => 'remove_room_participants';

  @override
  IRequestMethod get method => IRequestMethod.post;

  @override
  Json get body => <String, dynamic>{
        'room_id': roomId.toString(),
        'emails': userIds,
      };

  @override
  Iterable<String> format(Json json) {
    var ids = ((json['results'] as Map)['participants_removed'] as List) //
        .cast<String>();

    return ids;
  }
}
