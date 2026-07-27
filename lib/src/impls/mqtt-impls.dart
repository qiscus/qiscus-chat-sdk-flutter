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
  Timer? attachTimer;
  var listeners = <MultiStreamController<MqttUpdatesData>>{};
  var stream = Stream<MqttUpdatesData>.multi((controller) {
    listeners.add(controller);
    controller.onCancel = () => listeners.remove(controller);
  });

  // Menyambungkan ulang listener internal ke `mqtt.updates`.
  //
  // `mqtt.updates` bisa berupa instance stream yang BERBEDA setiap kali
  // koneksi dibangun ulang, jadi ini wajib dipanggil di setiap jalur
  // penyambungan - bukan hanya saat connect pertama.
  void attach() {
    attachTimer?.cancel();
    attachTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      var updates = mqtt.updates;
      if (updates == null) return;

      timer.cancel();
      attachTimer = null;
      subs?.cancel();
      subs = updates.listen(
        (v) {
          listeners.forEach((l) => l.addSync(v));
        },
        onError: (Object err, StackTrace stack) {
          listeners.forEach((l) => l.addErrorSync(err, stack));
        },
        onDone: () {
          // JANGAN tutup controller milik consumer di sini.
          //
          // Sebelumnya baris ini memanggil `l.closeSync()`, yang menutup
          // stream `onMessageReceived()` milik aplikasi secara PERMANEN
          // begitu stream MQTT internal selesai (terjadi setiap koneksi
          // dibangun ulang). Setelah itu tidak ada reconnect atau
          // re-subscribe apa pun yang bisa menghidupkannya kembali -
          // aplikasi harus restart. Stream consumer hanya boleh ditutup
          // lewat `clearUser()`.
          subs = null;
        },
      );
    });
  }

  mqtt.onConnected = attach;

  // `onConnected` TIDAK dipanggil pada jalur auto reconnect - `mqtt_client`
  // memakai callback terpisah. Tanpa baris ini, setelah auto reconnect
  // (kejadian normal di mobile: pindah jaringan, keluar dari background)
  // koneksi tersambung dan broker tetap mengirim pesan, tapi SDK tidak
  // pernah menyambungkan listener-nya lagi. Inilah "zombie connection"
  // yang dilaporkan: socket ESTABLISHED, MQTT connected, aplikasi buta.
  mqtt.onAutoReconnected = attach;

  // Catatan: dengan `autoReconnect = true`, `onDisconnected` hanya dipanggil
  // pada disconnect yang disengaja (mis. `clearUser()`), bukan pada putus
  // koneksi mendadak. Jadi ini murni jalur pembersihan.
  mqtt.onDisconnected = () {
    attachTimer?.cancel();
    attachTimer = null;
    subs?.cancel();
    subs = null;
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
