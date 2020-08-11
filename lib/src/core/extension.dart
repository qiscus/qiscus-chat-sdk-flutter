import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'errors.dart';
import 'mqtt/mqtt.dart';

class CMqttMessage {
  const CMqttMessage(this.topic, this.payload);

  final String topic;
  final String payload;
}

extension OptionDo<T> on Option<T> {
  // ignore: non_constant_identifier_names
  void do_(void Function(T data) onData) {
    fold(() {}, (it) => onData(it));
  }
}

extension MqttClientX on MqttClient {
  Either<QError, void> publishEvent(MqttEventHandler event) {
    var topic = event.topic;
    var message = event.publish();
    return publish(topic, message);
  }

  Stream<Output> subscribeEvent<Input, Output>(
    MqttEventHandler<Input, Output> event,
  ) async* {
    var topic = event.topic;

    await for (var data in forTopic(topic)) {
      yield* event.receive(data);
    }
  }

  Either<QError, void> publish(String topic, String message) {
    return catching<void>(() {
      var payload = MqttClientPayloadBuilder()..addString(message);
      publishMessage(topic, MqttQos.atLeastOnce, payload.payload);
    }).leftMapToQError();
  }

  Stream<CMqttMessage> forTopic(String topic) async* {
    if (updates == null) {
      yield* Stream.empty();
    } else {
      yield* MqttClientTopicFilter(topic, updates)
          .updates
          ?.expand((events) => events)
          ?.asyncMap((event) {
        var _payload = event.payload as MqttPublishMessage;
        var payload =
            MqttPublishPayload.bytesToStringAsString(_payload.payload.message);
        return CMqttMessage(event.topic, payload);
      });
    }
  }
}

extension CEither<L, R> on Either<L, R> {
  Either<L, R> tap(Function1<R, void> callback) {
    map((r) {
      try {
        callback(r);
        // ignore: avoid_catches_without_on_clauses
      } catch (_) {
        // do nothing
      }
    });
    return this;
  }

  Either<QError, R> leftMapToQError([String message]) {
    return leftMap((err) {
      if (err is DioError && err.response != null) {
        Map<String, dynamic> json;
        if (err.response.data is Map<String, dynamic>) {
          json = err.response.data as Map<String, dynamic>;
        } else {
          json =
              jsonDecode(err.response.data as String) as Map<String, dynamic>;
        }
        print('json: $json');
        if (message != null) {
          return QError(message);
        } else {
          var message = json['error']['message'] as String;
          return QError(message);
        }
      }
      return QError(err.toString());
    });
  }
}

extension TaskE<L, R> on Task<Either<L, R>> {
  Task<Either<QError, R>> leftMapToQError([String message]) {
    return map((either) => either.leftMapToQError(message));
  }

  Task<Either<O, R>> leftMap<O>(O Function(L) op) {
    return map((either) => either.leftMap(op));
  }

  Task<Either<L, O>> rightMap<O>(O Function(R) op) {
    return map((either) => either.map(op));
  }

  Task<Either<L, R>> tap(Function1<R, void> op) {
    return map((either) => either.tap(op));
  }
}

extension StreamTapped<T> on Stream<T> {
  Stream<T> tap(void Function(T) tapData) {
    return asyncMap((event) {
      try {
        tapData(event);
        // ignore: avoid_catches_without_on_clauses
      } catch (_) {
        // do nothing
      }
      return event;
    });
  }
}

extension FlatStream<V> on Stream<Stream<V>> {
  Stream<V> flatten() async* {
    await for (var val in this) {
      yield* val;
    }
  }
}

extension COption<T01> on Option<T01> {
  T01 unwrap([String message = 'null']) {
    return fold(
      () => throw QError(message),
      (value) => value,
    );
  }

  T01 toNullable() {
    return fold(
      () => null,
      (it) => it,
    );
  }
}

extension TaskX<L1, R1> on Task<Either<L1, R1>> {
  // ignore: non_constant_identifier_names
  void toCallback_(void Function(R1, L1) callback) {
    toCallback(callback).run();
  }

  Task<Either<void, void>> toCallback(void Function(R1, L1) callback) {
    return leftMap((err) {
      callback(null, err);
    }).rightMap((val) {
      callback(val, null);
    });
  }

  Task<Either<void, void>> toCallback1(void Function(L1) callback) {
    return leftMap((err) {
      callback(err);
    });
  }

  Future<R1> toFuture() {
    return run().then((either) => either.fold(
          (err) => Future<R1>.error(err),
          (data) => Future.value(data),
        ));
  }
}

extension FutureX<T> on Future<T> {
  void toCallback1(void Function(QError) callback) {
    then(
      (_) => callback(null),
      onError: (dynamic error) => callback(error as QError),
    );
  }

  void toCallback2(void Function(T, QError) callback) {
    then(
      (value) => callback(value, null),
      onError: (dynamic error) => callback(null, error as QError),
    );
  }
}

extension ObjectX on Object {
  Option<T> toOption<T>() {
    return optionOf<T>(this as T);
  }
}
