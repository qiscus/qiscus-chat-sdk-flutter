import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart';

class Debug {
  final MqttClient mqtt;
  final Stream<void> _interval;
  var _mqttSubscribedTopics = <String>[];

  final _topicSubscribedController = StreamController<String>.broadcast();
  final _topicUnsubscribedController = StreamController<String>.broadcast();

  Debug({required this.mqtt, required Stream<void> interval})
      : _interval = interval {
    mqtt.onSubscribed = (topic) {
      _mqttSubscribedTopics = [..._mqttSubscribedTopics, topic];
      _topicSubscribedController.add(topic);
    };

    mqtt.onUnsubscribed = (topic) {
      _mqttSubscribedTopics =
          _mqttSubscribedTopics.where((t) => t != topic).toList();
      if (topic != null) {
        _topicUnsubscribedController.add(topic);
      }
    };
  }

  Stream<String> get onMqttSubscribed => _topicSubscribedController.stream;
  Stream<String> get onMqttUnsubscribed => _topicUnsubscribedController.stream;

  Stream<Duration> interval() async* {
    var start = DateTime.now();

    await for (var _ in _interval) {
      var now = DateTime.now();
      var duration = now.difference(start);
      start = now;

      yield duration;
    }
  }

  Stream<MqttConnectionState> onMqttConnectionStatus({
    Duration interval = const Duration(seconds: 1),
    bool emitOnInterval = false,
  }) {
    var stream = Stream<MqttConnectionState>.periodic(
      interval,
      (_) => mqtt.connectionStatus?.state ?? MqttConnectionState.disconnected,
    );

    if (!emitOnInterval) {
      stream = stream.distinct();
    }

    return stream;
  }

  Stream<List<String>> onMqttSubscribedTopics() {
    var stream = Stream<List<String>>.periodic(const Duration(seconds: 1), (_) {
      return _mqttSubscribedTopics;
    }).distinct();

    return stream;
  }
}
