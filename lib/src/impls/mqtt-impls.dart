import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
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

  void detach() {
    subs?.cancel();
    subs = null;
  }

  // mqtt_client creates updates before invoking either connection callback.
  // Attach immediately; polling can outlive a disconnected SDK indefinitely.
  // Cancel first so repeated callbacks never stack source subscriptions.
  void attach() {
    if (listeners.isEmpty) return;
    var updates = mqtt.updates;
    if (updates == null) return;
    detach();
    subs = updates.listen(
      (v) {
        listeners.forEach((l) => l.addSync(v));
      },
      onError: (Object err, StackTrace stack) {
        listeners.forEach((l) => l.addErrorSync(err, stack));
      },
      // Only the source ended. Keep consumers open for the next connection.
      onDone: () => subs = null,
    );
  }

  var stream = Stream<MqttUpdatesData>.multi((controller) {
    listeners.add(controller);
    controller.onCancel = () {
      listeners.remove(controller);
      if (listeners.isEmpty) detach();
    };
    // Also handles late consumers and listening again after cancellation.
    if (subs == null &&
        mqtt.connectionStatus?.state == MqttConnectionState.connected) {
      attach();
    }
  });

  // Rantai callback yang sudah terpasang (mis. milik MqttConnectionTracker),
  // jangan ditimpa.
  var prevOnConnected = mqtt.onConnected;
  mqtt.onConnected = () {
    attach();
    prevOnConnected?.call();
  };

  // `onConnected` TIDAK dipanggil pada jalur auto reconnect - jalur itu punya
  // callback sendiri.
  //
  // Ini bersifat DEFENSIF, bukan perbaikan bug yang terbukti. Pada versi
  // dependensi saat ini auto reconnect tidak membangun ulang stream update-nya,
  // jadi subscription dari `onConnected` sebenarnya masih hidup. Tapi itu cuma
  // detail internal dependensi, bukan bagian dari kontrak publiknya; kalau
  // suatu versi mulai membangunnya ulang, tanpa baris ini SDK jadi buta
  // permanen setelah reconnect. Aman dipasang karena `attach()` idempoten.
  var prevOnAutoReconnected = mqtt.onAutoReconnected;
  mqtt.onAutoReconnected = () {
    attach();
    prevOnAutoReconnected?.call();
  };

  // Catatan: dengan `autoReconnect = true`, `onDisconnected` hanya dipanggil
  // pada disconnect yang disengaja (mis. `clearUser()`), bukan pada putus
  // koneksi mendadak. Jadi ini murni jalur pembersihan.
  var prevOnDisconnected = mqtt.onDisconnected;
  mqtt.onDisconnected = () {
    detach();
    prevOnDisconnected?.call();
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

// Only numeric room filters are safe to include in diagnostics. Other topics
// can contain an auth token or user identifier.
String mqttDiagnosticTopic(String topic) =>
    RegExp(r'^r/\d+/(\d+|\+)/\+/(r|d|t)$').hasMatch(topic) ||
            RegExp(r'^r/\d+/\d+/e$').hasMatch(topic)
        ? topic
        : '[redacted]';

final _mqttSubscribeInProgress = Expando<bool>();

bool mqttSubscribeInProgress(MqttClient mqtt) =>
    _mqttSubscribeInProgress[mqtt] ?? false;

final _mqttSubscribeErrors = Expando<void Function(QError)>();

void observeMqttSubscribeErrors(
    MqttClient mqtt, void Function(QError) onError) {
  _mqttSubscribeErrors[mqtt] = onError;
  final previousOnSubscribeFail = mqtt.onSubscribeFail;
  mqtt.onSubscribeFail = (topic) {
    // mqtt_client also invokes this synchronously on local failure; the wrapper
    // reports that failure once, with the local stage rather than SUBACK.
    if (!mqttSubscribeInProgress(mqtt)) {
      onError(QError(
          'MQTT asynchronous subscription failed for ${mqttDiagnosticTopic(topic)}; '
          'broker SUBACK rejected/empty or automatic re-subscribe failed '
          '(raw return code unavailable).'));
    }
    previousOnSubscribeFail?.call(topic);
  };
}

Reader<MqttClient, IOEither<QError, Unit>> mqttSubscribeTopic(
  String topic,
) {
  return Reader((mqtt) {
    return IOEither.tryCatch(() {
      // mqtt_client 9.8.1 falls through to onSubscribed on a failed SUBACK
      // unless this callback is non-null, even without an SDK/debug observer.
      mqtt.onSubscribeFail ??= (_) {};
      _mqttSubscribeInProgress[mqtt] = true;
      try {
        Subscription? subscription;
        try {
          subscription = mqtt.subscribe(topic, MqttQos.atLeastOnce);
        } catch (_) {
          // Unlike a null return, a thrown local error has no dependency callback.
          mqtt.onSubscribeFail?.call(topic);
          rethrow;
        }
        if (subscription == null) {
          throw QError('MQTT local subscription failed for '
              '${mqttDiagnosticTopic(topic)}: request was not queued.');
        }
        // A queued request is not a broker confirmation. SUBACK is asynchronous.
        return unit;
      } finally {
        _mqttSubscribeInProgress[mqtt] = false;
      }
    }, (e, st) {
      final error = QError(
          'MQTT local subscription failed for ${mqttDiagnosticTopic(topic)}; '
          'request was not queued (${e.runtimeType}).',
          st);
      _mqttSubscribeErrors[mqtt]?.call(error);
      return error;
    });
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

class QMqttCredentials {
  final String url;
  final String username;
  final String password;

  const QMqttCredentials({
    required this.url,
    required this.username,
    required this.password,
  });
}

class GetMqttCredentialRequest extends IApiRequest<Option<QMqttCredentials>> {
  @override
  format(Json json) {
    var node = Option.tryCatch(() {
      return json['results'] as Map<String, String>;
    }).flatMap((result) {
      return Option.Do((_) {
        var url = _(Option.fromNullable(result['url']));
        var username = _(Option.fromNullable(result['username']));
        var password = _(Option.fromNullable(result['password']));
        return QMqttCredentials(
          url: url,
          username: username,
          password: password,
        );
      });
    });

    return node;
  }

  @override
  IRequestMethod get method => IRequestMethod.get;

  @override
  String get url => '/api/v2/sdk/mqtt_config';
}

Reader<Dio, TaskEither<QError, Option<QMqttCredentials>>> getMqttNode() {
  return Reader((dio) {
    return TaskEither.tryCatch(() async {
      var req = GetMqttCredentialRequest();
      return req(dio);
    }, (_, __) {
      return QError('Failed getting a new mqtt url');
    });
  });
}
