import 'dart:async';
import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../core.dart';

typedef MqttUpdatesData = List<MqttReceivedMessage<MqttMessage>>;
typedef MqttUpdates = Stream<MqttUpdatesData>;

class QMqttMessage {
  const QMqttMessage(this.topic, this.payload);

  final String topic;
  final String payload;

  @override
  String toString() {
    return '{ topic: ($topic), payload: ($payload) }';
  }
}

StreamTransformer<MqttUpdatesData, QMqttMessage> mqttExpandTransformer =
    StreamTransformer.fromHandlers(handleData: (source, sink) {
  for (var data in source) {
    var payload = data.payload as MqttPublishMessage;
    var message = utf8.decode(payload.payload.message);
    var topic = data.topic;

    sink.add(QMqttMessage(topic, message));
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

final getMqttConnectionState = Reader((MqttClient mqtt) {
  return Stream.periodic(const Duration(milliseconds: 300),
      (_) => mqtt.connectionStatus?.state).distinct();
});

Stream<MqttUpdatesData> mqttUpdate2(MqttClient mqtt) {
  StreamSubscription<MqttUpdatesData>? subs;
  var listeners = <MultiStreamController<MqttUpdatesData>>{};
  var stream = Stream<MqttUpdatesData>.multi((controller) {
    listeners.add(controller);
    controller.onCancel = () => listeners.remove(controller);
  });

  mqtt.onConnected = () {
    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (mqtt.updates != null) {
        timer.cancel();
        subs?.cancel();
        subs = mqtt.updates!.listen(
          (v) {
            listeners.forEach((l) => l.addSync(v));
          },
          onError: (err, stack) {
            listeners.forEach((l) => l.addErrorSync(err, stack));
          },
          onDone: () {
            listeners.forEach((l) => l.closeSync());
          },
        );
      }
    });
  };
  mqtt.onDisconnected = () {
    subs?.cancel();
  };

  return stream;
}

Reader<MqttClient, MqttUpdates> mqttUpdates() {
  return Reader((mqtt) => mqttUpdate2(mqtt));
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

Reader<MqttClient, IOEither<QError, Unit>> mqttSubscribeTopic(
  String topic,
) {
  return Reader((mqtt) {
    return IOEither.tryCatch(() {
      try {
        mqtt.subscribe(topic, MqttQos.atLeastOnce);
      } on ConnectionException catch (_) {}
      return unit;
    }, (e, st) => QError(e.toString(), st));
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

Reader<MqttClient, IOEither<QError, Unit>> mqttSendEvent(
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
      (e, st) => QError(e.toString(), st),
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
