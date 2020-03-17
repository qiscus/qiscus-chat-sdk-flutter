import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/storage.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/service.dart';

@sealed
class TypingModel {
  final bool isTyping;
  final int roomId;
  final String userId;
  TypingModel({
    this.isTyping,
    this.roomId,
    this.userId,
  });
}

@immutable
class PublishTyping extends UseCase<RealtimeService, void, TypingModel> {
  final Storage _s;
  PublishTyping(
    RealtimeService repository,
    this._s,
  ) : super(repository);

  @override
  Task<Either<Exception, void>> call(p) {
    var userId = _s.userId;
    return Task(() async => repository.publishTyping(
          isTyping: p.isTyping,
          roomId: p.roomId,
          userId: userId,
        ));
  }
}

@immutable
class SubscribeTyping
    extends SubscriptionUseCase<RealtimeService, TypingModel, TypingModel> {
  SubscribeTyping(RealtimeService repository) : super(repository);

  @override
  Stream<TypingModel> subscribe(params) {
    return repository
        .subscribeUserTyping(
          roomId: params.roomId,
        )
        .asyncMap((event) => TypingModel(
              userId: event.userId,
              isTyping: event.isTyping,
              roomId: event.roomId,
            ));
  }
}

class PresenceParams {
  final bool isOnline;
  final DateTime lastSeen;
  final String userId;
  PresenceParams({
    this.isOnline,
    this.lastSeen,
    this.userId,
  });
}

@immutable
class PublishPresence extends UseCase<RealtimeService, void, PresenceParams> {
  final Storage _storage;
  const PublishPresence(RealtimeService service, this._storage)
      : super(service);

  @override
  Task<Either<Exception, void>> call(params) {
    return Task(() async => repository.publishPresence(
          isOnline: params.isOnline,
          lastSeen: params.lastSeen,
          userId: _storage.userId,
        ));
  }
}

@immutable
class SubscribePresence extends SubscriptionUseCase<RealtimeService,
    PresenceParams, PresenceParams> {
  SubscribePresence(RealtimeService repository) : super(repository);

  @override
  Stream<PresenceParams> subscribe(PresenceParams params) {
    return repository
        .subscribeUserPresence(userId: params.userId)
        .map((res) => PresenceParams(
              isOnline: res.isOnline,
              userId: res.userId,
              lastSeen: res.lastSeen,
            ));
  }
}
