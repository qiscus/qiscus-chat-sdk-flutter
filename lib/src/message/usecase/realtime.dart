part of qiscus_chat_sdk.usecase.message;

class RoomIdParams with EquatableMixin {
  const RoomIdParams(this.roomId);

  final int roomId;

  @override
  List<Object> get props => [roomId];

  @override
  bool get stringify => true;
}

class RoomUniqueIdsParams extends Equatable {
  const RoomUniqueIdsParams(this.uniqueId);

  final String uniqueId;

  @override
  List<Object> get props => [uniqueId];

  @override
  bool get stringify => true;
}

class OnMessageDeleted
    with SubscriptionMixin<IRealtimeService, TokenParams, Message> {
  OnMessageDeleted._(this._service);

  final IRealtimeService _service;

  factory OnMessageDeleted(IRealtimeService s) =>
      _instance ??= OnMessageDeleted._(s);
  static OnMessageDeleted _instance;

  @override
  Stream<Message> mapStream(_) => repository //
      .subscribeMessageDeleted();

  @override
  IRealtimeService get repository => _service;

  @override
  Option<String> topic(TokenParams p) {
    return Option.some(TopicBuilder.notification(p.token));
  }
}

class OnMessageRead
    with SubscriptionMixin<IRealtimeService, RoomIdParams, Message> {
  OnMessageRead._(this._service);

  final IRealtimeService _service;

  factory OnMessageRead(IRealtimeService s) => _instance ??= OnMessageRead._(s);
  static OnMessageRead _instance;

  @override
  Stream<Message> mapStream(RoomIdParams p) {
    return repository.subscribeMessageRead(roomId: p.roomId);
  }

  @override
  Option<String> topic(RoomIdParams p) {
    return Option.some(TopicBuilder.messageRead(p.roomId.toString()));
  }

  @override
  IRealtimeService get repository => _service;
}

class TokenParams with EquatableMixin {
  const TokenParams(this.token);

  final String token;

  @override
  List<Object> get props => [token];

  @override
  bool get stringify => true;
}

class OnMessageReceived
    with SubscriptionMixin<IRealtimeService, TokenParams, Message> {
  OnMessageReceived._(this._service, this._updateMessageStatus) {
    _receiveMessage = StreamTransformer.fromHandlers(
      handleData: (message, sink) async {
        sink.add(message);

        var roomId = message.chatRoomId;
        var messageId = message.id;
        var status = QMessageStatus.delivered;

        await roomId.fold(() async {}, (roomId) {
          return _updateMessageStatus(
            UpdateStatusParams(roomId, messageId.toNullable(), status),
          );
        });
      },
    );
  }

  final IRealtimeService _service;
  final UpdateMessageStatusUseCase _updateMessageStatus;
  StreamTransformer<Message, Message> _receiveMessage;

  factory OnMessageReceived(
    IRealtimeService s,
    UpdateMessageStatusUseCase us,
  ) {
    return _instance ??= OnMessageReceived._(s, us);
  }

  static OnMessageReceived _instance;

  @override
  Stream<Message> mapStream(p) => repository //
      .subscribeMessageReceived()
      .transform(_receiveMessage);

  @override
  IRealtimeService get repository => _service;

  @override
  Option<String> topic(TokenParams p) {
    return Option.some(TopicBuilder.messageNew(p.token));
  }
}

class OnMessageUpdated
    with SubscriptionMixin<IRealtimeService, TokenParams, Message> {
  OnMessageUpdated._(this.repository);

  static OnMessageUpdated _instance;
  @override
  final IRealtimeService repository;

  factory OnMessageUpdated(IRealtimeService s) =>
      _instance ??= OnMessageUpdated._(s);

  @override
  Stream<Message> mapStream(p) => repository.subscribeMessageUpdated();

  @override
  Option<String> topic(TokenParams p) {
    return Option.some(TopicBuilder.messageUpdated(p.token));
  }
}

class OnMessageDelivered
    with SubscriptionMixin<IRealtimeService, RoomIdParams, Message> {
  OnMessageDelivered._(this._service);

  final IRealtimeService _service;

  factory OnMessageDelivered(IRealtimeService s) =>
      _instance ??= OnMessageDelivered._(s);
  static OnMessageDelivered _instance;

  @override
  Stream<Message> mapStream(RoomIdParams p) {
    return repository.subscribeMessageDelivered(roomId: p.roomId);
  }

  @override
  IRealtimeService get repository => _service;

  @override
  Option<String> topic(RoomIdParams p) {
    return Option.some(TopicBuilder.messageDelivered(p.roomId.toString()));
  }
}
