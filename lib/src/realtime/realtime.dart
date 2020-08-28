library qiscus_chat_sdk.realtime;

import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

import '../features/message/message.dart';

part 'message_delivered.dart';
part 'message_received.dart';

enum RealtimeSyncTopic {
  messageReceived,
  messageDelivered,
  messageRead,
  messageDeleted,
  roomCleared,
  userTyping,
  userPresence,
}

mixin IRealtimeEvent<Output extends Object> {
  /// mqtt topic which this event should subscribe
  Option<String> get mqttTopic;

  /// mqtt data which this event will send
  Option<String> get mqttData;

  /// sync topic which this event should listen
  Option<RealtimeSyncTopic> get syncTopic;

  Stream<Output> mqttMapper(String payload);

  Stream<Output> syncMapper(Map<String, dynamic> payload);
}

@sealed
abstract class IRealtimeService {
  Task<void> publish<In>(IRealtimeEvent event);

  Task<Stream<Out>> subscribe<Out>(IRealtimeEvent event);
}
