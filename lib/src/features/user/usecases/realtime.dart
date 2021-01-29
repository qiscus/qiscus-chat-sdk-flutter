part of qiscus_chat_sdk.usecase.user;

class TypingUseCase extends UseCase<IRealtimeService, void, UserTyping>
    with SubscriptionMixin<IRealtimeService, UserTyping, UserTyping> {
  TypingUseCase._(IRealtimeService repository) : super(repository);

  factory TypingUseCase(IRealtimeService repo) =>
      _instance ??= TypingUseCase._(repo);
  static TypingUseCase _instance;

  @override
  Task<Either<QError, void>> call(params) {
    return task(
      () => repository.publishTyping(
          isTyping: params.isTyping,
          userId: params.userId,
          roomId: params.roomId),
    );
  }

  @override
  Stream<UserTyping> mapStream(params) => repository
      .subscribeUserTyping(roomId: params.roomId)
      .asyncMap((res) => UserTyping(
            isTyping: res.isTyping,
            roomId: res.roomId,
            userId: res.userId,
          ));

  @override
  Option<String> topic(UserTyping p) =>
      some(TopicBuilder.typing(p.roomId.toString(), p.userId));
}

@immutable
class PresenceUseCase extends UseCase<IRealtimeService, void, UserPresence>
    with SubscriptionMixin<IRealtimeService, UserPresence, UserPresence> {
  PresenceUseCase._(IRealtimeService service) : super(service);
  static PresenceUseCase _instance;

  factory PresenceUseCase(IRealtimeService service) =>
      _instance ??= PresenceUseCase._(service);

  @override
  Task<Either<QError, void>> call(params) {
    return task(() {
      return repository.publishPresence(
        isOnline: params.isOnline,
        lastSeen: params.lastSeen,
        userId: params.userId,
      );
    });
  }

  @override
  Stream<UserPresence> mapStream(UserPresence params) => repository
      .subscribeUserPresence(userId: params.userId)
      .asyncMap((res) => UserPresence(
            userId: res.userId,
            lastSeen: res.lastSeen,
            isOnline: res.isOnline,
          ));

  @override
  Option<String> topic(UserPresence p) => some(TopicBuilder.presence(p.userId));
}
