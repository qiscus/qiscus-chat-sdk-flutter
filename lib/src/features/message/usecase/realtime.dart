import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/realtime.dart';

import '../entity.dart';

class RoomIdParams extends Equatable {
  const RoomIdParams(this.roomId);

  final int roomId;

  @override
  List<Object> get props => [roomId];

  @override
  bool get stringify => true;
}

class OnMessageDeleted with Subscription<RealtimeService, NoParams, Message> {
  OnMessageDeleted._(this._service);

  final RealtimeService _service;

  factory OnMessageDeleted(RealtimeService s) =>
      _instance ??= OnMessageDeleted._(s);
  static OnMessageDeleted _instance;

  @override
  Stream<Message> mapStream(_) => repository //
      .subscribeMessageDeleted()
      .asyncMap((res) => Message(
            id: -1,
            uniqueId: optionOf(res.messageUniqueId),
            chatRoomId: optionOf(res.messageRoomId),
          ));

  @override
  RealtimeService get repository => _service;
}

abstract class _MessageSubscription<Params>
    with Subscription<RealtimeService, Params, Message> {
  _MessageSubscription(this._service);

  final RealtimeService _service;

  @override
  RealtimeService get repository => _service;

  @override
  Task<Stream<Message>> subscribe(params) => repository //
      .subscribe(topicFor(params))
      .andThen(super.subscribe(params));

  String topicFor(Params p);
}

class OnMessageRead extends _MessageSubscription<RoomIdParams> {
  OnMessageRead._(RealtimeService s) : super(s);

  factory OnMessageRead(RealtimeService s) => _instance ??= OnMessageRead._(s);
  static OnMessageRead _instance;

  @override
  Stream<Message> mapStream(p) => repository
      .subscribeMessageRead(roomId: p.roomId)
      .asyncMap((res) => Message(
            id: int.parse(res.commentId),
            chatRoomId: optionOf(res.roomId),
            uniqueId: optionOf(res.commentUniqueId),
          ));

  @override
  String topicFor(p) => TopicBuilder.messageRead(p.roomId.toString());
}

class TokenParams extends Equatable {
  const TokenParams(this.token);

  final String token;

  @override
  List<Object> get props => [token];

  @override
  bool get stringify => true;
}

class OnNotification
    with Subscription<RealtimeService, TokenParams, Notification> {
  OnNotification._(this._service);

  final RealtimeService _service;

  factory OnNotification(RealtimeService s) =>
      _instance ??= OnNotification._(s);
  static OnNotification _instance;

  @override
  Stream<Notification> mapStream(TokenParams p) {
    return null;
  }

  @override
  RealtimeService get repository => _service;
}

class OnMessageReceived
    with Subscription<RealtimeService, TokenParams, Message> {
  OnMessageReceived._(this._service);

  final RealtimeService _service;

  factory OnMessageReceived(RealtimeService s) =>
      _instance ??= OnMessageReceived._(s);
  static OnMessageReceived _instance;

  @override
  Task<Stream<Message>> subscribe(p) => repository
      .subscribe(TopicBuilder.messageNew(p.token))
      .andThen(super.subscribe(p));

  @override
  Stream<Message> mapStream(p) => repository.subscribeMessageReceived();

  @override
  RealtimeService get repository => _service;
}

class OnMessageDelivered extends _MessageSubscription<RoomIdParams> {
  OnMessageDelivered._(RealtimeService s) : super(s);

  factory OnMessageDelivered(RealtimeService s) =>
      _instance ??= OnMessageDelivered._(s);
  static OnMessageDelivered _instance;

  @override
  Stream<Message> mapStream(RoomIdParams p) => repository
      .subscribeMessageDelivered(roomId: p.roomId)
      .asyncMap((res) => Message(
            id: int.parse(res.commentId),
            chatRoomId: optionOf(res.roomId),
            uniqueId: optionOf(res.commentUniqueId),
          ));

  @override
  RealtimeService get repository => _service;

  @override
  String topicFor(p) => TopicBuilder.messageDelivered(p.roomId.toString());
}
