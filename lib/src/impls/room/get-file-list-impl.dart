import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/message/message-model.dart';
import 'package:qiscus_chat_sdk/src/impls/message/message-from-json-impl.dart';

RTE<Iterable<QMessage>> getFileListImpl({
  List<int>? roomIds,
  String? fileType,
  List<String>? includeExtensions,
  List<String>? excludeExtensions,
  String? userId,
  int? page,
  int? limit,
  String? query,
}) {
  return tryCR((dio) async {
    var req = FileListRequest(
      roomIds: roomIds,
      fileType: fileType,
      includeExtensions: includeExtensions,
      excludeExtensions: excludeExtensions,
      sender: userId,
      page: page,
      limit: limit,
      query: query,
    );
    return req(dio);
  });
}

class FileListRequest extends IApiRequest<Iterable<QMessage>> {
  const FileListRequest({
    required this.roomIds,
    required this.fileType,
    required this.sender,
    required this.query,
    required this.page,
    required this.limit,
    this.includeExtensions = const [],
    this.excludeExtensions = const [],
  });

  final String? query;
  final String? sender;
  final List<int>? roomIds;
  final String? fileType;
  final List<String>? includeExtensions;
  final List<String>? excludeExtensions;
  final int? page;
  final int? limit;

  @override
  IRequestMethod get method => IRequestMethod.post;

  @override
  Json get body => <String, dynamic>{
        'query': query,
        'room_ids': roomIds?.map((it) => it.toString()).toList(),
        'sender': sender,
        'file_type': fileType,
        'include_extensions': includeExtensions,
        'exclude_extensions': excludeExtensions,
        'page': page,
        'limit': limit,
      };

  @override
  Iterable<QMessage> format(Json json) sync* {
    var results = json['results'] as Json;
    var comments = (results['comments'] as List).cast<Json>();

    for (var comment in comments) {
      yield messageFromJson(comment);
    }
  }

  @override
  String get url => 'file_list';
}
