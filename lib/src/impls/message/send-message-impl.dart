import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/message/message-model.dart';
import 'package:qiscus_chat_sdk/src/impls/message/message-from-json-impl.dart';

RTE<State<Iterable<QMessage>, QMessage>> sendMessageImpl(QMessage message) {
  return Reader((Dio dio) {
    return tryCatch(() async {
      var req = SendMessageRequest(
        roomId: message.chatRoomId,
        message: message.text,
        uniqueId: message.uniqueId,
      );
      var m = await req(dio);

      return State((Iterable<QMessage> s) {
        return Tuple2(m, [...s, m]);
      });
    });
  });
}

class SendMessageRequest extends IApiRequest<QMessage> {
  final int roomId;
  final String message;
  final String type;
  final String uniqueId;
  final Map<String, dynamic>? extras;
  final Map<String, dynamic>? payload;

  SendMessageRequest({
    required this.roomId,
    required this.message,
    required this.uniqueId,
    this.type = 'text',
    this.extras,
    this.payload,
  });

  @override
  String get url => 'post_comment';
  @override
  IRequestMethod get method => IRequestMethod.post;
  @override
  Map<String, dynamic> get body => <String, dynamic>{
        'topic_id': roomId.toString(),
        'comment': message,
        'type': type,
        'unique_temp_id': uniqueId,
        'payload': payload,
        'extras': extras,
      };

  @override
  QMessage format(Map<String, dynamic> json) {
    var data = json['results']['comment'] as Map<String, dynamic>;
    return messageFromJson(data);
  }
}
