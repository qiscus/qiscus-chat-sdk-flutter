import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/message/message-model.dart';
import 'package:qiscus_chat_sdk/src/impls/message/message-from-json-impl.dart';

ReaderTaskEither<Dio, String, Iterable<QMessage>> deleteMessagesImpl(
    List<String> uniqueIds) {
  return Reader((Dio dio) {
    return TaskEither.tryCatch(() async {
      var req = DeleteMessagesRequest(uniqueIds: uniqueIds);
      return req(dio);
    }, (e, _) => e.toString());
  });
}

class DeleteMessagesRequest extends IApiRequest<Iterable<QMessage>> {
  final List<String> uniqueIds;
  final bool isHardDelete;
  final bool isForEveryone;

  DeleteMessagesRequest({
    required this.uniqueIds,
    this.isForEveryone = true,
    this.isHardDelete = true,
  });

  @override
  String get url => 'delete_messages';
  @override
  IRequestMethod get method => IRequestMethod.delete;
  @override
  Json get params => <String, dynamic>{
        'unique_ids': uniqueIds,
        'is_hard_delete': isHardDelete,
        'is_delete_for_everyone': isForEveryone,
      };

  @override
  Iterable<QMessage> format(Json json) sync* {
    var data = ((json['results'] as Map?)?['comments'] as List) //
        .cast<Json>();

    for (var item in data) {
      yield messageFromJson(item);
    }
  }
}
