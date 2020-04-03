import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/mqtt_service_impl.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/service.dart';

@sealed
class Typing with EquatableMixin {
  final bool isTyping;
  final int roomId;
  final String userId;

  Typing({
    this.isTyping,
    this.roomId,
    this.userId,
  });

  @override
  List<Object> get props => [userId, roomId];

  @override
  bool get stringify => true;
}

@sealed
class Presence with EquatableMixin {
  final bool isOnline;
  final DateTime lastSeen;
  final String userId;

  Presence({
    this.isOnline,
    this.lastSeen,
    this.userId,
  });

  @override
  List<Object> get props => [userId];
}

class TypingUseCase extends UseCase<RealtimeService, void, Typing>
    with Subscription<RealtimeService, Typing, Typing> {
  TypingUseCase._(RealtimeService repository) : super(repository);

  factory TypingUseCase(RealtimeService repo) =>
      _instance ??= TypingUseCase._(repo);
  static TypingUseCase _instance;

  @override
  Task<Either<Exception, void>> call(params) =>
      Task.delay(() => repository.publishTyping(
            isTyping: params.isTyping,
            userId: params.userId,
            roomId: params.roomId,
          ));

  @override
  Task<Stream<Typing>> subscribe(Typing params) => repository
      .subscribe(TopicBuilder.typing(params.roomId.toString(), params.userId))
      .andThen(super.subscribe(params));

  @override
  Stream<Typing> mapStream(params) => repository
      .subscribeUserTyping(roomId: params.roomId)
      .asyncMap((res) => Typing(
            isTyping: res.isTyping,
            roomId: res.roomId,
            userId: res.userId,
          ));

  @override
  Task<void> unsubscribe(Typing params) {
    return super.unsubscribe(params);
  }

  @override
  Option<String> topic(Typing p) =>
      some(TopicBuilder.typing(p.roomId.toString(), p.userId));
}

@immutable
class PresenceUseCase extends UseCase<RealtimeService, void, Presence>
    with Subscription<RealtimeService, Presence, Presence> {
  PresenceUseCase._(RealtimeService service) : super(service);
  static PresenceUseCase _instance;

  factory PresenceUseCase(RealtimeService service) =>
      _instance ??= PresenceUseCase._(service);

  @override
  Task<Stream<Presence>> subscribe(Presence params) => repository
      .subscribe(TopicBuilder.presence(params.userId))
      .andThen(super.subscribe(params));

  @override
  Task<Either<Exception, void>> call(params) =>
      Task.delay(() => repository.publishPresence(
            isOnline: params.isOnline,
            lastSeen: params.lastSeen,
            userId: params.userId,
          ));

  @override
  Stream<Presence> mapStream(Presence params) =>
      repository
          .subscribeUserPresence(userId: params.userId)
          .asyncMap((res) =>
          Presence(
            userId: res.userId,
            lastSeen: res.lastSeen,
            isOnline: res.isOnline,
          ));

  @override
  Option<String> topic(Presence p) => some(TopicBuilder.presence(p.userId));
}
