import 'package:dartz/dartz.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';
import 'package:qiscus_chat_sdk/src/core/storage.dart';

class LocalMqttClient extends MqttServerClient {
  LocalMqttClient(this._storage)
      : super.withPort(
          _storage.brokerUrl,
          'dart-sdk-${_storage.appId}-${DateTime.now().millisecondsSinceEpoch}',
          _storage.brokerPort,
        );

  final Storage _storage;

  @override
  Future<MqttClientConnectionStatus> connect([
    String username,
    String password,
  ]) {
    var connectionMessage = MqttConnectMessage() //
        .withWillTopic('u/${_storage.currentUser.id}/s')
        .withWillMessage('0')
        .withWillRetain();
    this.connectionMessage = connectionMessage;
    return super.connect(username, password);
  }

  Either<Exception, void> publish(String topic, String message) {
    return catching<void>(() {
      var payload = MqttClientPayloadBuilder()..addString(message);
      super.publishMessage(topic, MqttQos.atLeastOnce, payload.payload);
    }).leftMapToException();
  }

  Stream<MqttReceivedMessage<MqttMessage>> forTopic(String topic) {
    return MqttClientTopicFilter(topic, updates)
        .updates
        .expand((events) => events);
  }
}
