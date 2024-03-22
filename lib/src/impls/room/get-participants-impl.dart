import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/user/user-model.dart';
import 'package:qiscus_chat_sdk/src/impls/user/participant-from-json-impl.dart';

ReaderTaskEither<Dio, QError, Iterable<QParticipant>> getParticipantsImpl(
  String roomUniqueId, {
  int? page,
  int? limit,
  String? sorting,
}) {
  return Reader((dio) {
    return tryCatch(() async {
      return GetParticipantRequest(
        roomUniqueId: roomUniqueId,
        page: page,
        limit: limit,
        sorting: sorting,
      )(dio);
    });
  });
}

class GetParticipantRequest extends IApiRequest<Iterable<QParticipant>> {
  const GetParticipantRequest({
    required this.roomUniqueId,
    required this.page,
    required this.limit,
    required this.sorting,
  });

  final String roomUniqueId;
  final int? page;
  final int? limit;
  final String? sorting;

  @override
  String get url => 'room_participants';

  @override
  IRequestMethod get method => IRequestMethod.get;

  @override
  Json get params => <String, dynamic>{
        'room_unique_id': roomUniqueId,
        'page': page,
        'limit': limit,
        'sorting': sorting,
      };

  @override
  Iterable<QParticipant> format(Json json) sync* {
    var participants_ = ((json['results'] as Map)['participants'] as List) //
        .cast<Json>();

    for (var json in participants_) {
      yield participantFromJson(json);
    }
  }
}
