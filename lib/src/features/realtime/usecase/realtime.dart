import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/realtime.dart';

class OnConnected with Subscription<RealtimeService, NoParams, void> {
  OnConnected._(this._repo);

  factory OnConnected(RealtimeService repo) =>
      _instance ??= OnConnected._(repo);
  static OnConnected _instance;
  final RealtimeService _repo;

  @override
  Stream<void> mapStream(_) => repository.onConnected();

  @override
  RealtimeService get repository => _repo;

  @override
  Option<String> topic(NoParams p) => none();
}

class OnDisconnected with Subscription<RealtimeService, NoParams, void> {
  OnDisconnected._(this._repo);

  final RealtimeService _repo;

  factory OnDisconnected(RealtimeService repo) =>
      _instance ??= OnDisconnected._(repo);
  static OnDisconnected _instance;

  @override
  RealtimeService get repository => _repo;

  @override
  Stream<void> mapStream(_) => repository.onDisconnected();

  @override
  Option<String> topic(NoParams p) => none();
}

class OnReconnecting with Subscription<RealtimeService, NoParams, void> {
  OnReconnecting._(this._repo);

  final RealtimeService _repo;

  factory OnReconnecting(RealtimeService repo) =>
      _instance ??= OnReconnecting._(repo);
  static OnReconnecting _instance;

  @override
  RealtimeService get repository => _repo;

  @override
  Stream<void> mapStream(_) => repository.onReconnecting();

  @override
  Option<String> topic(NoParams p) => none();
}
