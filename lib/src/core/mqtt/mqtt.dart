import '../core.dart';
import '_mqtt_stub.dart'
    if (dart.library.js) '_mqtt_web.dart'
    if (dart.library.io) '_mqtt_server.dart';

MqttClient makeMqttClient(Storage storage) {
  return getMqttClient(storage);
}

abstract class MqttEventHandler<InData, OutData> {
  const MqttEventHandler();

  String get topic;

  String publish();

  Stream<OutData> receive(CMqttMessage message);
}
