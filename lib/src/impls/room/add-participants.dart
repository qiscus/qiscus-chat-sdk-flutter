import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/user/user-model.dart';
import 'package:qiscus_chat_sdk/src/impls/user/participant-from-json-impl.dart';

Reader<Dio, TaskEither<String, Iterable<QParticipant>>> addParticipantsImpl(
  int roomId,
  List<String> userIds,
) {
  return Reader(
    (Dio dio) => TaskEither.tryCatch(() async {
      var req = AddParticipantRequest(roomId: roomId, userIds: userIds);
      var res = await req(dio);

      return res;
    }, (e, _) => e.toString()),
  );
}

class AddParticipantRequest extends IApiRequest<Iterable<QParticipant>> {
  const AddParticipantRequest({
    required this.roomId,
    required this.userIds,
  });

  final int roomId;
  final List<String> userIds;

  @override
  String get url => 'add_room_participants';

  @override
  IRequestMethod get method => IRequestMethod.post;

  @override
  Json get body => <String, dynamic>{
        'room_id': roomId.toString(),
        'emails': userIds,
      };

  @override
  Iterable<QParticipant> format(Json json) sync* {
    var participants =
        ((json['results'] as Map?)?['participants_added'] as List).cast<Json>();

    for (var item in participants) {
      yield participantFromJson(item);
    }
  }
}
