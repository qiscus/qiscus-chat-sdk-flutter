import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:qiscus_chat_sdk/src/core/storage.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/mqtt_service_impl.dart';

MqttClient getMqtt() {
  final connMsg = MqttConnectMessage() //
      .withClientIdentifier('sdk-dart')
      .withWillTopic('u/guest-1002/s')
      .withWillMessage('0')
      .withWillRetain()
      .startClean();

  var brokerUrl = 'wss://mqtt.qiscus.com/mqtt';
  var client = MqttServerClient.withPort(brokerUrl, 'sdk-dart', 1886)
        // ..logging(on: true)
        ..logging(on: false)
        ..useWebSocket = true
        ..connectionMessage = connMsg
        ..websocketProtocols = MqttClientConstants.protocolsSingleDefault
      //
      ;

  client.onSubscribed = (topic) => print('subscribe: $topic');
  client.onDisconnected = () => print('on disconnected');
  client.onConnected = () => print('client connected');
  return client;
}

var token = 'DliiUcM3RdiRtlTyYpHK';
var roomId = 3143607;
var topic1 = '$token/c';
var topic2 = 'r/$roomId/+/+/t';

void main() {
  var client = getMqtt();
  var storage = Storage();
  storage.token = token;
  var service = MqttServiceImpl(() => client, storage);

  service.subscribe(topic1).run().then((either) {
    either.fold(
      (e) => print('error while subscribe: $e'),
      (_) => print('right'),
    );
  });
  service.subscribeMessageReceived().listen((data) {
    print('got new message: $data');
  });

  // await client.connect();
}

void main1() async {
  var client = getMqtt();
  await client.connect();

  var token = 'DliiUcM3RdiRtlTyYpHK';
  var roomId = 3143607;
  var topic1 = '$token/c';
  var topic2 = 'r/$roomId/+/+/t';

  client.subscribe(topic1, MqttQos.atLeastOnce);
  client.subscribe(topic2, MqttQos.atLeastOnce);

  client.forTopic(topic2).listen((data) {
    var topic = data.topic;
    print('got data for topic: $topic');
  });
  client.forTopic(topic1).listen((data) {
    var topic = data.topic;
    print('got data for topic: $topic');
  });
}

class CMqttMessage {
  const CMqttMessage(this.topic, this.payload);
  final String topic;
  final String payload;
}

extension on MqttClient {
  Stream<CMqttMessage> forTopic(String topic) {
    return MqttClientTopicFilter(topic, updates).updates.asyncMap((msgs) {
      return Stream.fromIterable(msgs.map((msg) {
        var topic = msg.topic;
        var _msg = msg.payload as MqttPublishMessage;
        var payload =
            MqttPublishPayload.bytesToStringAsString(_msg.payload.message);
        return CMqttMessage(topic, payload);
      }));
    }).asyncExpand((it) => it);
  }
}
