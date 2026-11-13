import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart';

import 'core.dart' show QError;
import 'impls/mqtt-impls.dart'
    show mqttDiagnosticTopic, mqttSubscribeInProgress;

class Debug {
  final MqttClient mqtt;
  final Stream<void> _interval;
  var _mqttSubscribedTopics = <String>[];

  final _topicSubscribedController = StreamController<String>.broadcast();
  final _topicUnsubscribedController = StreamController<String>.broadcast();
  final _subscribeFailedController = StreamController<QError>.broadcast();

  Debug({required this.mqtt, required Stream<void> interval})
      : _interval = interval {
    final previousOnSubscribed = mqtt.onSubscribed;
    mqtt.onSubscribed = (topic) {
      _mqttSubscribedTopics = [..._mqttSubscribedTopics, topic];
      _topicSubscribedController.add(mqttDiagnosticTopic(topic));
      previousOnSubscribed?.call(topic);
    };

    final previousOnUnsubscribed = mqtt.onUnsubscribed;
    mqtt.onUnsubscribed = (topic) {
      _mqttSubscribedTopics =
          _mqttSubscribedTopics.where((t) => t != topic).toList();
      if (topic != null) {
        _topicUnsubscribedController.add(mqttDiagnosticTopic(topic));
      }
      previousOnUnsubscribed?.call(topic);
    };

    final previousOnSubscribeFail = mqtt.onSubscribeFail;
    mqtt.onSubscribeFail = (topic) {
      final local = mqttSubscribeInProgress(mqtt);
      _subscribeFailedController.add(QError(
          'MQTT ${local ? 'local' : 'asynchronous'} subscription failed for '
          '${mqttDiagnosticTopic(topic)}; '
          '${local ? 'request was not queued.' : 'broker SUBACK rejected/empty or automatic re-subscribe failed (raw return code unavailable).'}'));
      previousOnSubscribeFail?.call(topic);
    };
  }

  /// Sanitized subscription failures; broker callbacks expose no raw SUBACK code.
  Stream<QError> get onMqttSubscribeFailed => _subscribeFailedController.stream;

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
      return _mqttSubscribedTopics.map(mqttDiagnosticTopic).toList();
    }).distinct();

    return stream;
  }
}
