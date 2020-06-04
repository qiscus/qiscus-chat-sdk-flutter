import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/realtime.dart';

import '../entity.dart';
import '../message.dart';

class RoomIdParams extends Equatable {
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
    with Subscription<RealtimeService, TokenParams, Message> {
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

  @override
  Option<String> topic(p) => some(TopicBuilder.notification(p.token));
}

class OnMessageRead with Subscription<RealtimeService, RoomIdParams, Message> {
  OnMessageRead._(this._service);

  final RealtimeService _service;

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
  Option<String> topic(p) =>
      some(TopicBuilder.messageRead(p.roomId.toString()));

  @override
  RealtimeService get repository => _service;
}

class TokenParams extends Equatable {
  const TokenParams(this.token);

  final String token;

  @override
  List<Object> get props => [token];

  @override
  bool get stringify => true;
}

class OnMessageReceived
    with Subscription<RealtimeService, TokenParams, Message> {
  OnMessageReceived._(this._service, this._updateMessageStatus);

  final RealtimeService _service;
  final UpdateMessageStatusUseCase _updateMessageStatus;

  factory OnMessageReceived(RealtimeService s, UpdateMessageStatusUseCase us) =>
      _instance ??= OnMessageReceived._(s, us);
  static OnMessageReceived _instance;

  @override
  Task<Stream<Message>> subscribe(p) => repository
      .subscribe(TopicBuilder.messageNew(p.token))
      .andThen(super.subscribe(p));

  @override
  Task<void> unsubscribe(TokenParams params) {
    return super.unsubscribe(params);
  }

  @override
  Stream<Message> mapStream(p) =>
      repository.subscribeMessageReceived() //
          .transform(StreamTransformer.fromHandlers(
        handleData: (message, sink) async {
          sink.add(message);

          var roomId = message.chatRoomId;
          var messageId = message.id;
          var status = QMessageStatus.delivered;
          var res = roomId.fold<Task<Either<Exception, Unit>>>(
                  () => Task.delay(() => right(unit)),
                  (roomId) =>
                  _updateMessageStatus.call(UpdateStatusParams(
                    roomId,
                    messageId,
                    status,
                  )));
          await res.run();
        },
      )) //
      ;

  @override
  RealtimeService get repository => _service;

  @override
  Option<String> topic(TokenParams p) => some(TopicBuilder.messageNew(p.token));
}

class OnMessageDelivered
    with Subscription<RealtimeService, RoomIdParams, Message> {
  OnMessageDelivered._(this._service);

  final RealtimeService _service;

  factory OnMessageDelivered(RealtimeService s) =>
      _instance ??= OnMessageDelivered._(s);
  static OnMessageDelivered _instance;

  @override
  Stream<Message> mapStream(RoomIdParams p) =>
      repository.subscribeMessageDelivered(roomId: p.roomId).asyncMap((res) {
        return Message(
          id: int.parse(res.commentId),
          chatRoomId: optionOf(res.roomId),
          uniqueId: optionOf(res.commentUniqueId),
        );
      });

  @override
  RealtimeService get repository => _service;

  @override
  Option<String> topic(p) =>
      some(TopicBuilder.messageDelivered(p.roomId.toString()));
}
