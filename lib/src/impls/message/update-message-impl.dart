import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/message/message-model.dart';
import 'package:qiscus_chat_sdk/src/impls/message/message-from-json-impl.dart';

RTE<State<Iterable<QMessage>, QMessage>> updateMessageImpl(QMessage message) {
  return tryCR((dio) async {
    var req = UpdateMessageRequest(message: message);

    var msg = await req(dio);
    return State((messages) =>
        Tuple2(msg, [...messages.where((it) => it.id != msg.id), msg]));
  });
}

class UpdateMessageRequest extends IApiRequest<QMessage> {
  const UpdateMessageRequest({required this.message});

  final QMessage message;

  @override
  IRequestMethod get method => IRequestMethod.post;

  @override
  String get url => 'update_message';

  @override
  QMessage format(Json json) {
    var data = (json['results'] as Map?)?['comment'] as Json;
    return messageFromJson(data);
  }

  @override
  Json get body {
    var m = message;
    var data = <String, dynamic>{
      'room_id': m.chatRoomId,
      'unique_id': m.uniqueId,
      'comment': m.text,
    };
    if (m.payload != null) {
      data['payload'] = m.payload;
    }
    if (m.extras != null) {
      data['extras'] = m.extras;
    }
    return data;
  }
}
