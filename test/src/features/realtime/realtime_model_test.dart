import 'package:qiscus_chat_sdk/src/realtime/realtime.dart';
import 'package:test/test.dart';

import 'json.dart';

void main() {
  var events = (eventJson['events'] as List).cast<Map<String, dynamic>>();

  group('RealtimeEvent model', () {
    test('should parse json successfully', () {
      //
      var json = eventJson;

      var res = RealtimeEvent.fromJson(json);

      var read = res.whereType<MessageReadEvent>();
      var delivered = res.whereType<MessageDeliveredEvent>();
      var roomCleared = res.whereType<RoomClearedEvent>();
      var msgDeleted = res.whereType<MessageDeletedEvent>();

      expect(read.length, 1);
      expect(delivered.length, 1);
      expect(roomCleared.length, 1);
      expect(msgDeleted.length, 1);

      expect(read.first.messageId, 123);
      expect(read.first.messageUniqueId, '123--');
      expect(read.first.roomId, 1234);
      expect(read.first.userId, 'user-id');

      expect(delivered.first.messageId, 123);
      expect(delivered.first.messageUniqueId, '123--');
      expect(delivered.first.roomId, 1234);
      expect(delivered.first.userId, 'user-id');

      expect(msgDeleted.first.roomId, 12345);
      expect(msgDeleted.first.messageUniqueId, '12345');

      expect(roomCleared.first.roomId, 123);

      var unknownEvent = res.whereType<UnknownEvent>();
      expect(unknownEvent.first.actionType, 'clear_room_unknown');
    });
  });

  group('MessageReadEvent', () {
    var json = events.firstWhere((event) => event['action_topic'] == 'read');

    test('should parse json successfully', () {
      var data = MessageReadEvent.fromJson(json);
      expect(data.messageId, 123);
      expect(data.messageUniqueId, '123--');
      expect(data.roomId, 1234);
      expect(data.userId, 'user-id');
    });

    test('equality', () {
      var data1 = MessageReadEvent.fromJson(json);
      var data2 = MessageReadEvent.fromJson(json);

      expect(data1, data2);
    });
  });

  group('MessageDeliveredEvent', () {
    var json = events.firstWhere((it) => it['action_topic'] == 'delivered');

    test('should parse json successfully', () {
      var data = MessageDeliveredEvent.fromJson(json);
      expect(data.messageId, 123);
      expect(data.messageUniqueId, '123--');
      expect(data.roomId, 1234);
      expect(data.userId, 'user-id');
    });

    test('equality', () {
      var data1 = MessageDeliveredEvent.fromJson(json);
      var data2 = MessageDeliveredEvent.fromJson(json);

      expect(data1, data2);
    });
  });

  group('MessageDeletedEvent', () {
    var json =
        events.firstWhere((it) => it['action_topic'] == 'delete_message');

    test('should parse json successfully', () {
      var data = MessageDeletedEvent.fromJson(json);
      expect(data.first.roomId, 12345);
      expect(data.first.messageUniqueId, '12345');
    });

    test('equality', () {
      var data1 = MessageDeletedEvent.fromJson(json);
      var data2 = MessageDeletedEvent.fromJson(json);
      expect(data1, data2);
    });
  });

  group('RoomClearedEvent', () {
    var json = events //
        .firstWhere((it) => it['action_topic'] == 'clear_room');

    test('should parse json successfully', () {
      var data = RoomClearedEvent.fromJson(json);
      expect(data.first.roomId, 123);
    });

    test('equality', () {
      var data1 = RoomClearedEvent.fromJson(json);
      var data2 = RoomClearedEvent.fromJson(json);
      expect(data1, data2);
    });
  });

  group('UnknownEvent', () {
    var json = events.firstWhere((it) {
      final knownType = [
        'read',
        'delivered',
        'clear_room',
        'delete_message',
      ];

      return !knownType.contains(it['action_topic'] as String);
    });

    test('equality', () {
      var event1 = UnknownEvent.fromJson(json);
      var event2 = UnknownEvent.fromJson(json);

      expect(event1, event2);
    });
  });
}
