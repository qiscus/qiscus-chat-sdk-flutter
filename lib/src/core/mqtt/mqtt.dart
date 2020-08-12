import '../core.dart';
export '_mqtt_stub.dart'
    if (dart.library.html) '_mqtt_web.dart'
    if (dart.library.io) '_mqtt_server.dart';

abstract class MqttEventHandler<InData, OutData> {
  const MqttEventHandler();
  String get topic;
  String publish();
  Stream<OutData> receive(CMqttMessage message);
}
