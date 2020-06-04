import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';
import 'package:qiscus_chat_sdk/src/core/storage.dart';
import 'package:qiscus_chat_sdk/src/features/message/entity.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/service.dart';
import 'package:sealed_unions/factories/doublet_factory.dart';
import 'package:sealed_unions/implementations/union_2_impl.dart';
import 'package:sealed_unions/union_2.dart';

class MqttServiceImpl implements RealtimeService {
  MqttServiceImpl(this._getClient, this._s, this._logger, this._dio) {
    _mqtt.onConnected = () => log('on mqtt connected');
    _mqtt.onDisconnected = () {
      log('on mqtt disconnected');
      _onDisconnected(_mqtt.connectionStatus);
    };
    _mqtt.onSubscribed = (topic) {
      _subscribedTopics.add(topic);
      log('on mqtt subscribed: $topic');
    };
    _mqtt.onUnsubscribed = (topic) => log('on mqtt unsubscribed: $topic');

    _mqtt
        .connect()
        .then((status) => log('connected to mqtt: $status'))
        .catchError((dynamic error) => log('cannot connect to mqtt: $error'));
    _mqtt.updates.expand((it) => it).listen((event) {
      var p = event.payload as MqttPublishMessage;
      var payload = MqttPublishPayload.bytesToStringAsString(p.payload.message);
      var topic = event.topic;
      log('on-message: $topic -> $payload');
    });
  }

  void log(String str) => _logger.log('MqttServiceImpl::- $str');

  void _onDisconnected(MqttClientConnectionStatus connectionStatus) async {
    // if connected state are not disconnected
    if (connectionState.state != MqttConnectionState.disconnected) {
      log('Mqtt disconnected with unknown state: ${connectionStatus.state}');
      return;
    }

    // get a new broker url by calling lb
    var result = await _dio.get<Map<String, dynamic>>(_s.brokerLbUrl);
    var data = result.data['data'] as Map<String, dynamic>;
    var url = data['url'] as String;
    var port = data['wss_port'] as String;
    var newUrl = 'wss://$url:$port/mqtt';
    _s.brokerUrl = newUrl;
    try {
      __mqtt = getMqttClient(_s);
      await _mqtt.connect();
    } catch (e) {
      log('got error when reconnecting mqtt: $e');
    }
  }

  final Dio _dio;
  final Logger _logger;

  final MqttClient Function() _getClient;
  MqttClient __mqtt;
  final Storage _s;
  final _subscribedTopics = <String>[];

  MqttClient get _mqtt => __mqtt ??= _getClient();

  Future<bool> get _isConnected => Stream<bool>.periodic(
          const Duration(milliseconds: 300))
      .map((_) => _mqtt.connectionStatus.state == MqttConnectionState.connected)
      .distinct()
      .firstWhere((it) => it == true);

  Task<Either<Exception, void>> _connected() =>
      Task<bool>(() => _isConnected).attempt().leftMapToException();

  @override
  Task<Either<Exception, void>> subscribe(String topic) => _connected()
      .andThen(Task.delay(
          () => catching(() => _mqtt.subscribe(topic, MqttQos.atLeastOnce))))
      .leftMapToException();

  @override
  Task<Either<Exception, void>> unsubscribe(String topic) => _connected()
      .andThen(Task.delay(() => catching(() => _mqtt.unsubscribe(topic))))
      .leftMapToException();

  @override
  bool get isConnected =>
      _mqtt?.connectionStatus?.state == MqttConnectionState.connected ?? false;

  @override
  MqttClientConnectionStatus get connectionState => _mqtt?.connectionStatus;

  Stream<Notification> get _notification {
    return _mqtt
        ?.forTopic(TopicBuilder.notification(_s.token))
        ?.asyncMap<List<Notification>>((event) {
      var jsonPayload =
          jsonDecode(event.payload.toString()) as Map<String, dynamic>;
      var actionType = jsonPayload['action_topic'] as String;
      var payload = jsonPayload['payload'] as Map<String, dynamic>;
      var actorId = payload['actor']['id'] as String;
      var actorEmail = payload['actor']['email'] as String;
      var actorName = payload['actor']['name'] as String;

      if (actionType == 'delete_message') {
        var mPayload =
            payload['data']['deleted_messages'] as List<Map<String, dynamic>>;
        return mPayload
            .map((m) {
              var roomId = m['room_id'] as String;
              var uniqueIds = m['message_unique_ids'] as List<String>;
              return uniqueIds.map(
                (uniqueId) => Tuple2(int.parse(roomId), uniqueId),
              );
            })
            .expand((it) => it)
            .map(
              (tuple) => Notification.message_deleted(
                actorId: actorId,
                actorEmail: actorEmail,
                actorName: actorName,
                roomId: tuple.value1,
                messageUniqueId: tuple.value2,
              ),
            )
            .toList(growable: false);
      }

      if (actionType == 'clear_room') {
        var rooms_ =
            payload['data']['deleted_rooms'] as List<Map<String, dynamic>>;
        return rooms_.map((r) {
          return Notification.room_cleared(
            actorId: actorId,
            actorEmail: actorEmail,
            actorName: actorName,
            roomId: r['id'] as int,
          );
        }).toList(growable: false);
      }

      return [];
    })?.expand((it) => it);
  }

  @override
  Either<Exception, void> publishPresence({
    bool isOnline,
    DateTime lastSeen,
    String userId,
  }) {
    var millis = lastSeen.millisecondsSinceEpoch;
    var payload = isOnline ? '1' : '0';
    return _mqtt?.publish(TopicBuilder.presence(userId), '$payload:$millis');
  }

  @override
  Either<Exception, void> publishTyping({
    bool isTyping,
    String userId,
    int roomId,
  }) {
    var payload = isTyping ? '1' : '0';
    return _mqtt?.publish(
      TopicBuilder.typing(roomId.toString(), userId),
      payload,
    );
  }

  @override
  Stream<MessageReceivedResponse> subscribeChannelMessage({String uniqueId}) {
    return _mqtt
        ?.forTopic(TopicBuilder.channelMessageNew('', uniqueId))
        ?.asyncMap((event) {
      // appId/channelId/c;
      var messageData = event.payload.toString();
      var messageJson = jsonDecode(messageData) as Map<String, dynamic>;
      var response = MessageReceivedResponse.fromJson(messageJson);

      return response;
    });
  }

  @override
  Stream<MessageDeletedResponse> subscribeMessageDeleted() {
    return _notification
        .asyncMap(
          (notification) => notification.join(
            (message) => message.toResponse(),
            (_) => MessageDeletedResponse(),
          ),
        )
        .where((it) => it.messageUniqueId != null);
  }

  @override
  Stream<MessageDeliveryResponse> subscribeMessageDelivered({int roomId}) {
    return _mqtt
        ?.forTopic(TopicBuilder.messageDelivered(roomId.toString()))
        ?.where((it) => int.parse(it.topic.split('/')[1]) == roomId)
        ?.asyncMap((msg) {
      // r/{roomId}/{roomId}/{userId}/d
      // {commentId}:{commentUniqueId}
      var payload = msg.payload.toString().split(':');
      var commentId = optionOf(payload[0]);
      var commentUniqueId = optionOf(payload[1]);
      return MessageDeliveryResponse(
        roomId: roomId,
        commentId: commentId.unwrap('commentId are null'),
        commentUniqueId: commentUniqueId.unwrap('commentUniqueId are null'),
      );
    });
  }

  @override
  Stream<MessageDeliveryResponse> subscribeMessageRead({int roomId}) {
    return _mqtt
        ?.forTopic(TopicBuilder.messageRead(roomId.toString()))
        ?.where((it) => int.parse(it.topic.split('/')[1]) == roomId)
        ?.asyncMap((msg) {
      // r/{roomId}/{roomId}/{userId}/r
      // {commentId}:{commentUniqueId}
      var payload = msg.payload.toString().split(':');
      var commentId = optionOf(payload[0]);
      var commentUniqueId = optionOf(payload[1]);
      return MessageDeliveryResponse(
        roomId: roomId,
        commentId: commentId.unwrap('commentId are null'),
        commentUniqueId: commentUniqueId.unwrap('commentUniqueId are null'),
      );
    });
  }

  @override
  Stream<Message> subscribeMessageReceived() {
    var decode = (String str) => jsonDecode(str) as Map<String, dynamic>;
    return _mqtt
        .forTopic(TopicBuilder.messageNew(_s.token))
        .asyncMap((CMqttMessage it) => decode(it.payload.toString()))
        .asyncMap((json) => Message.fromJson(json));
  }

  @override
  Stream<RoomClearedResponse> subscribeRoomCleared() {
    return _notification
        .asyncMap(
          (notification) => notification.join(
            (message) => RoomClearedResponse(),
            (room) => room.toResponse(),
          ),
        )
        .where((res) => res.room_id != null);
  }

  @override
  Stream<UserPresenceResponse> subscribeUserPresence({String userId}) {
    return _mqtt.forTopic(TopicBuilder.presence(userId)).asyncMap((msg) {
      // u/{userId}/s
      // 1:{timestamp}
      // 0:{timestamp}
      var payload = msg.payload.toString().split(':');
      var userId_ = msg.topic.split('/')[1];
      var onlineStatus =
          optionOf(payload[0]).map((str) => str == '1' ? true : false);
      var timestamp = optionOf(payload[1])
          .map((str) => DateTime.fromMillisecondsSinceEpoch(int.parse(str)));
      return UserPresenceResponse(
        userId: userId_,
        isOnline: onlineStatus.unwrap('onlineStatus are null'),
        lastSeen: timestamp.unwrap('lastSeen are null'),
      );
    });
  }

  @override
  Stream<UserTypingResponse> subscribeUserTyping({int roomId}) {
    // r/{roomId}/{roomId}/{userId}/t
    // 1
    return _mqtt
        .forTopic(TopicBuilder.typing(roomId.toString(), '+'))
        .asyncMap((msg) {
      var payload = msg.payload.toString();
      var topic = msg.topic.split('/');
      var roomId_ = optionOf(topic[1]).map((id) => int.parse(id));
      var userId_ = optionOf(topic[3]);
      return UserTypingResponse(
        roomId: roomId_.unwrap('roomId are null'),
        userId: userId_.unwrap('userId are null'),
        isTyping: payload == '1',
      );
    });
  }

  @override
  Stream<CustomEventResponse> subscribeCustomEvent({int roomId}) {
    // r/{roomId}/{roomId}/c
    return _mqtt.forTopic(TopicBuilder.customEvent(roomId)).asyncMap((msg) {
      var _payload = msg.payload.toString();
      var payload = jsonDecode(_payload) as Map<String, dynamic>;
      return CustomEventResponse(roomId, payload);
    });
  }

  @override
  Either<Exception, void> end() {
    return catching<void>(() {
      _subscribedTopics.forEach((topic) {
        var status = _mqtt.getSubscriptionsStatus(topic);
        if (status == MqttSubscriptionStatus.active) {
          _mqtt.unsubscribe(topic);
        }
      });
      _subscribedTopics.clear();
      _mqtt.disconnect();
    }).leftMapToException();
  }

  @override
  Stream<void> onConnected() =>
      Stream<void>.periodic(const Duration(milliseconds: 300))
          .asyncMap((_) =>
              _mqtt.connectionStatus.state == MqttConnectionState.connected)
          .distinct()
          .where((it) => it == true);

  @override
  Stream<void> onDisconnected() =>
      Stream<void>.periodic(const Duration(milliseconds: 300))
          .asyncMap((_) =>
              _mqtt.connectionStatus.state == MqttConnectionState.disconnected)
          .distinct()
          .where((it) => it == true);

  @override
  Stream<void> onReconnecting() =>
      Stream<void>.periodic(const Duration(milliseconds: 300))
          .asyncMap((_) =>
              _mqtt.connectionStatus.state == MqttConnectionState.disconnecting)
          .distinct()
          .where((it) => it == true);

  @override
  Either<Exception, void> publishCustomEvent({
    int roomId,
    Map<String, dynamic> payload,
  }) {
    return _mqtt.publish(TopicBuilder.customEvent(roomId), jsonEncode(payload));
  }

  @override
  Task<Either<Exception, Unit>> synchronize([int lastMessageId]) {
    return Task.delay(() => left(Exception('Not implemented')));
  }

  @override
  Task<Either<Exception, Unit>> synchronizeEvent([String lastEventId]) {
    return Task.delay(() => left(Exception('Not implemented')));
  }
}

abstract class TopicBuilder {
  static String typing(String roomId, String userId) =>
      'r/$roomId/$roomId/$userId/t';

  static String presence(String userId) => 'u/$userId/s';

  static String messageDelivered(String roomId) => 'r/$roomId/+/+/d';

  static String notification(String token) => '$token/n';

  static String messageRead(String roomId) => 'r/$roomId/+/+/r';

  static String messageNew(String token) => '$token/c';

  static String channelMessageNew(String appId, String channelId) =>
      '$appId/$channelId/c';

  static String customEvent(int roomId) => 'r/$roomId/$roomId/e';
}

// region Json payload for notification
/*
{
  "action_topic": "delete_message",
  "payload": {
    "actor": {
      "id": "user id",
      "email": "user email",
      "name": "user name"
    },
    "data": {
      "is_hard_delete": true,
      "deleted_messages": [
        {
          "room_id": "room id",
          "message_unique_ids": ["abc", "hajjes"]
        }
      ]
    }
  }
}
{
  "action_topic": "clear_room",
  "payload": {
    "actor": {
      "id": "user id",
      "email": "user email",
      "name": "user name"
    },
    "data": {
      "deleted_rooms": [
        {
           "avatar_url": "https://qiscuss3.s3.amazonaws.com/uploads/55c0c6ee486be6b686d52e5b9bbedbbf/2.png",
           "chat_type": "single",
           "id": 80,
           "id_str": "80",
           "options": {},
           "raw_room_name": "asasmoyo@outlook.com kotak@outlook.com",
           "room_name": "kotak",
           "unique_id": "72058999c5d64c61bca7deed53963aa1",
           "last_comment": null
        }
      ]
    }
  }
}
*/
// endregion

@sealed
class Notification extends Union2Impl<MessageDeleted, RoomCleared> {
  Notification._(Union2<MessageDeleted, RoomCleared> union) : super(union);

  static final Doublet<MessageDeleted, RoomCleared> factory =
      const Doublet<MessageDeleted, RoomCleared>();

  factory Notification.message_deleted({
    String actorId,
    String actorEmail,
    String actorName,
    int roomId,
    String messageUniqueId,
  }) =>
      Notification._(factory.first(MessageDeleted(
        actorId: actorId,
        actorName: actorName,
        actorEmail: actorEmail,
        roomId: roomId,
        messageUniqueId: messageUniqueId,
      )));

  factory Notification.room_cleared({
    String actorId,
    String actorEmail,
    String actorName,
    int roomId,
  }) =>
      Notification._(factory.second(RoomCleared(
        actorId: actorId,
        actorEmail: actorEmail,
        actorName: actorName,
        roomId: roomId,
      )));
}

@sealed
class MessageDeleted {
  final String actorId, actorEmail, actorName, messageUniqueId;
  final int roomId;

  MessageDeleted({
    this.actorId,
    this.actorEmail,
    this.actorName,
    this.messageUniqueId,
    this.roomId,
  });

  MessageDeletedResponse toResponse() => MessageDeletedResponse(
        actorId: actorId,
        actorEmail: actorEmail,
        actorName: actorName,
        messageRoomId: roomId,
        messageUniqueId: messageUniqueId,
      );
}

@sealed
class RoomCleared {
  final String actorId, actorEmail, actorName;
  final int roomId;

  RoomCleared({
    this.actorId,
    this.actorEmail,
    this.actorName,
    this.roomId,
  });

  RoomClearedResponse toResponse() => RoomClearedResponse(room_id: roomId);
}
