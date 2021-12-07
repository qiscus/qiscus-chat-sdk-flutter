import 'dart:async';
import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:mqtt_client/mqtt_client.dart';

typedef MqttUpdatesData = List<MqttReceivedMessage<MqttMessage>>;
typedef MqttUpdates = Stream<MqttUpdatesData>;

class QMqttMessage {
  const QMqttMessage(this.topic, this.payload);

  final String topic;
  final String payload;
}

StreamTransformer<MqttUpdatesData, QMqttMessage> mqttExpandTransformer =
    StreamTransformer.fromBind((source) async* {
  var stream = source.expand((it) => it);
  await for (var data in stream) {
    var payload = data.payload as MqttPublishMessage;
    var message = utf8.decode(payload.payload.message);
    var topic = data.topic;

    yield QMqttMessage(topic, message);
  }
});

Reader<MqttClient, IO<Stream<bool>>> mqttConnectionState() {
  return Reader((mqtt) {
    return IO(() {
      return Stream.periodic(const Duration(milliseconds: 300), (_) {
        return mqtt.connectionStatus?.state == MqttConnectionState.connected;
      }).distinct();
    });
  });
}

Reader<MqttClient, IO<MqttUpdates>> mqttUpdates() {
  return Reader((mqtt) {
    return mqttConnectionState() //
        .run(mqtt)
        .map((it) => _restartSubscription(it, () => mqtt.updates!));
  });
}

Reader<MqttClient, IO<Stream<QMqttMessage>>> mqttForTopic(
  String topic,
) {

  return Reader((mqtt) {
    var connected$ = mqttConnectionState().run(mqtt);
    return connected$.map((it) {
      var stream = MqttClientTopicFilter(topic, mqtt.updates).updates;
      var source = stream.transform(mqttExpandTransformer);
      return _restartSubscription(it, () => source);
    });
  });
}

Reader<MqttClient, IOEither<String, Unit>> mqttSubscribeTopic(
  String topic,
) {
  return Reader((mqtt) {
    return IOEither.tryCatch(() {
      mqtt.subscribe(topic, MqttQos.atLeastOnce);
      return unit;
    }, (e, _) => e.toString());
  });
}

Reader<MqttClient, IOEither<String, Unit>> mqttUnsubscribeTopic(String topic) {
  return Reader((mqtt) {
    return IOEither.tryCatch(() {
      mqtt.unsubscribe(topic);
      return unit;
    }, (e, _) => e.toString());
  });
}

Reader<MqttClient, IOEither<String, Unit>> mqttSendEvent(
  String topic,
  String payload,
) {
  return Reader((MqttClient mqtt) {
    return IOEither.tryCatch(
      () {
        var p = MqttClientPayloadBuilder().addString(payload).payload!;
        mqtt.publishMessage(topic, MqttQos.atLeastOnce, p);
        return unit;
      },
      (e, _) => e.toString(),
    );
  });
}

Stream<O> _restartSubscription<O>(
    Stream<bool> isConnected$, Stream<O> Function() source) {
  StreamSubscription<bool>? subs0;
  StreamSubscription<O>? subs1;
  StreamController<O>? controller;

  controller = StreamController<O>(
    onListen: () {
      subs0 = isConnected$.listen((isConnected) {
        if (!isConnected) {
          subs1?.cancel();
        } else {
          subs1 = source().listen((data) => controller?.sink.add(data));
        }
      });
    },
    onPause: () {
      subs0?.pause();
      subs1?.pause();
    },
    onResume: () {
      subs0?.resume();
      subs1?.resume();
    },
    onCancel: () {
      subs0?.cancel();
      subs1?.cancel();
    },
  );

  return controller.stream;
}
