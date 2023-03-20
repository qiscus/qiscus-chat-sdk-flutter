import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';

ReaderTaskEither<Dio, String, Unit> clearMessagesImpl(
  List<String> roomUniqueIds,
) {
  return Reader((Dio dio) {
    return tryCatch(() async {
      var req = ClearMessagesRequest(roomUniqueIds);
      return req(dio).then((_) => unit);
    });
  });
}

class ClearMessagesRequest extends IApiRequest<void> {
  ClearMessagesRequest(this.roomUniqueIds);

  final List<String> roomUniqueIds;

  @override
  String get url => 'clear_room_messages';

  @override
  IRequestMethod get method => IRequestMethod.delete;

  @override
  Json get params => <String, dynamic>{
        'room_channel_ids': roomUniqueIds,
      };

  @override
  void format(_) => null;
}
