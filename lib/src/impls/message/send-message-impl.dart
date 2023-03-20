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
        type: message.type.toString(),
        extras: message.extras,
        payload: message.payload,
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
  final Json? extras;
  final Json? payload;

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
  Json get body => <String, dynamic>{
        'topic_id': roomId.toString(),
        'comment': message,
        'type': type,
        'unique_temp_id': uniqueId,
        'payload': payload,
        'extras': extras,
      };

  @override
  QMessage format(Json json) {
    var data = ((json['results'] as Map?)?['comment'] as Json);
    return messageFromJson(data);
  }
}
