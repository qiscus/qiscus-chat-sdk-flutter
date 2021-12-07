import 'package:fpdart/fpdart.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/impls/mqtt-impls.dart';

Reader<Tuple2<MqttClient, Storage>, IOEither<String, Unit>>
publishOnlinePresenceImpl(bool isOnline, [DateTime? lastSeen]) {
  return Reader((r) {
    var topic = TopicBuilder.presence(r.second.userId!);
    var payload = isOnline ? '1' : '0';
    var millis = lastSeen?.millisecondsSinceEpoch ??
        DateTime.now().millisecondsSinceEpoch;

    return mqttSendEvent(topic, '$payload:$millis').run(r.first);
  });
}
