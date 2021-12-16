part of qiscus_chat_sdk.usecase.user;

class TypingUseCase extends UseCase<IRealtimeService, void, UserTyping>
    with SubscriptionMixin<IRealtimeService, UserTyping, UserTyping> {
  TypingUseCase(IRealtimeService repository) : super(repository);

  @override
  Future<void> call(UserTyping params) {
    return repository.publishTyping(
      isTyping: params.isTyping,
      userId: params.userId,
      roomId: params.roomId,
    );
  }

  @override
  Stream<UserTyping> mapStream(UserTyping params) => repository
      .subscribeUserTyping(roomId: params.roomId)
      .asyncMap((res) => UserTyping(
            isTyping: res.isTyping,
            roomId: res.roomId,
            userId: res.userId,
          ));

  @override
  Option<String> topic(UserTyping p) {
    return Option.some(TopicBuilder.typing(p.roomId.toString(), p.userId));
  }
}

@immutable
class PresenceUseCase extends UseCase<IRealtimeService, void, UserPresence>
    with SubscriptionMixin<IRealtimeService, UserPresence, UserPresence> {
  PresenceUseCase(IRealtimeService service) : super(service);

  @override
  Future<void> call(UserPresence params) {
    return repository.publishPresence(
      isOnline: params.isOnline,
      lastSeen: params.lastSeen,
      userId: params.userId,
    );
  }

  @override
  Stream<UserPresence> mapStream(UserPresence params) {
    return repository
        .subscribeUserPresence(userId: params.userId)
        .asyncMap((res) => UserPresence(
              userId: res.userId,
              lastSeen: res.lastSeen,
              isOnline: res.isOnline,
            ));
  }

  @override
  Option<String> topic(UserPresence p) {
    return Option.some(TopicBuilder.presence(p.userId));
  }
}
