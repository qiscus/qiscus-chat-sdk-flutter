import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mqtt_client/mqtt_client.dart';

class CMqttMessage {
  const CMqttMessage(this.topic, this.payload);
  final String topic;
  final String payload;
}

extension OptionDo<T> on Option<T> {
  void do_(void Function(T data) onData) {
    fold(() {}, (it) => onData(it));
  }
}

extension CMqttClient on MqttClient {
  Either<Exception, void> publish(String topic, String message) {
    return catching<void>(() {
      var payload = MqttClientPayloadBuilder()..addString(message);
      publishMessage(topic, MqttQos.atLeastOnce, payload.payload);
    }).leftMapToException();
  }

  Stream<CMqttMessage> forTopic(String topic) {
    return MqttClientTopicFilter(topic, updates)
        .updates
        .expand((events) => events)
        .asyncMap((event) {
      var _payload = event.payload as MqttPublishMessage;
      var payload =
          MqttPublishPayload.bytesToStringAsString(_payload.payload.message);
      return CMqttMessage(event.topic, payload);
    });
  }
}

extension CEither<L, R> on Either<L, R> {
  Either<L, R> tap(Function1<R, void> callback) {
    map((r) {
      try {
        callback(r);
      } catch (_) {
        // do nothing
      }
    });
    return this;
  }

  Either<Exception, R> leftMapToException([String message]) {
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
          return Exception(message);
        } else {
          var message = json['error']['message'] as String;
          return Exception(message);
        }
      }
      return Exception(err.toString());
    });
  }
}

extension TaskE<L, R> on Task<Either<L, R>> {
  Task<Either<Exception, R>> leftMapToException([String message]) {
    return map((either) => either.leftMapToException(message));
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
      () => throw Exception(message),
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
  void toCallback1(void Function(Exception) callback) {
    this.then(
      (_) => callback(null),
      onError: (Object error) => callback(error as Exception),
    );
  }

  void toCallback2(void Function(T, Exception) callback) {
    this.then(
      (value) => callback(value, null),
      onError: (Object error) => callback(null, error as Exception),
    );
  }
}
