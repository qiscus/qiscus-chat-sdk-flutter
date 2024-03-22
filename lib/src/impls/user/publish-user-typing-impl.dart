import 'package:fpdart/fpdart.dart';
import 'package:mqtt_client/mqtt_client.dart';
import '../../core.dart';
import '../mqtt-impls.dart';

Reader<Tuple2<MqttClient, Storage>, IOEither<QError, Unit>>
    publishUserTypingImpl({required int roomId, bool? isTyping = true}) {
  return Reader((r) {
    var topic = TopicBuilder.typing(roomId.toString(), r.second.userId!);
    var payload = isTyping == true ? '1' : '0';

    return mqttSendEvent(topic, payload).run(r.first);
  });
}
