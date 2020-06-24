import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core/storage.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/service.dart';

class Interval {
  Interval(
    this._storage,
    this._mqttClient,
  );

  final Storage _storage;
  final RealtimeService _mqttClient;
  bool _stopped = false;

  int get _interval => _mqttClient.isConnected
      ? _storage.syncIntervalWhenConnected
      : _storage.syncInterval;

  void start() {
    if (_stopped) _stopped = false;
  }

  void stop() {
    if (!_stopped) _stopped = true;
  }

  Stream<Unit> interval() async* {
    var accumulator = 0;
    var interval = Stream.periodic(
      Duration(milliseconds: _storage.accSyncInterval),
      (_) => accumulator += _storage.accSyncInterval,
    );

    await for (var interval_ in interval) {
      if (!_stopped && interval_ > _interval) {
        accumulator = 0;
        yield unit;
      }
    }
  }
}
