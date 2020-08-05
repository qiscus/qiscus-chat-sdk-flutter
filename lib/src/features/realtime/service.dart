import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../../core/core.dart';
import '../custom_event/entity.dart';
import '../message/message.dart';
import '../room/room.dart';
import '../user/user.dart';

abstract class IRealtimeService {
  MqttClientConnectionStatus get connectionState;

  bool get isConnected;

  Either<QError, void> end();

  Task<Either<QError, void>> subscribe(String topic);

  Task<Either<QError, void>> unsubscribe(String topic);

  Stream<void> onConnected();

  Stream<void> onReconnecting();

  Stream<void> onDisconnected();

  Stream<Message> subscribeMessageReceived();

  Stream<Message> subscribeMessageDelivered({
    @required int roomId,
  });

  Stream<CustomEvent> subscribeCustomEvent({
    @required int roomId,
  });

  Stream<Message> subscribeMessageRead({
    @required int roomId,
  });

  Stream<Message> subscribeMessageDeleted();

  Stream<ChatRoom> subscribeRoomCleared();

  Stream<Message> subscribeChannelMessage({
    @required String uniqueId,
  });

  Stream<UserTyping> subscribeUserTyping({
    @required int roomId,
  });

  Stream<UserPresence> subscribeUserPresence({
    @required String userId,
  });

  Either<QError, void> publishTyping({
    @required bool isTyping,
    @required String userId,
    @required int roomId,
  });

  Either<QError, void> publishPresence({
    bool isOnline,
    DateTime lastSeen,
    String userId,
  });

  Either<QError, void> publishCustomEvent({
    @required int roomId,
    @required Map<String, dynamic> payload,
  });

  Task<Either<QError, Unit>> synchronize([int lastMessageId]);
  Task<Either<QError, Unit>> synchronizeEvent([String lastEventId]);
}
