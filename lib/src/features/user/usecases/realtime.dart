part of qiscus_chat_sdk.usecase.user;

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

class TypingUseCase extends UseCase<IRealtimeService, void, Typing>
    with SubscriptionMixin<IRealtimeService, Typing, Typing> {
  TypingUseCase._(IRealtimeService repository) : super(repository);

  factory TypingUseCase(IRealtimeService repo) =>
      _instance ??= TypingUseCase._(repo);
  static TypingUseCase _instance;

  @override
  Task<Either<QError, void>> call(params) =>
      Task.delay(() => repository.publishTyping(
            isTyping: params.isTyping,
            userId: params.userId,
            roomId: params.roomId,
          ));

  @override
  Stream<Typing> mapStream(params) => repository
      .subscribeUserTyping(roomId: params.roomId)
      .asyncMap((res) => Typing(
            isTyping: res.isTyping,
            roomId: res.roomId,
            userId: res.userId,
          ));

  @override
  Option<String> topic(Typing p) =>
      some(TopicBuilder.typing(p.roomId.toString(), p.userId));
}

@immutable
class PresenceUseCase extends UseCase<IRealtimeService, void, Presence>
    with SubscriptionMixin<IRealtimeService, Presence, Presence> {
  PresenceUseCase._(IRealtimeService service) : super(service);
  static PresenceUseCase _instance;

  factory PresenceUseCase(IRealtimeService service) =>
      _instance ??= PresenceUseCase._(service);

  @override
  Task<Either<QError, void>> call(params) =>
      Task.delay(() => repository.publishPresence(
            isOnline: params.isOnline,
            lastSeen: params.lastSeen,
            userId: params.userId,
          ));

  @override
  Stream<Presence> mapStream(Presence params) => repository
      .subscribeUserPresence(userId: params.userId)
      .asyncMap((res) => Presence(
            userId: res.userId,
            lastSeen: res.lastSeen,
            isOnline: res.isOnline,
          ));

  @override
  Option<String> topic(Presence p) => some(TopicBuilder.presence(p.userId));
}
