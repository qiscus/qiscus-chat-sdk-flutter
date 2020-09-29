import 'package:qiscus_chat_sdk/src/features/realtime/realtime.dart';
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
    });
  });

  group('MessageReadEvent', () {
    test('should parse json successfully', () {
      var json = events.firstWhere((event) => event['action_topic'] == 'read');

      var data = MessageReadEvent.fromJson(json);
      expect(data.messageId, 123);
      expect(data.messageUniqueId, '123--');
      expect(data.roomId, 1234);
      expect(data.userId, 'user-id');
    });
  });

  group('MessageDeliveredEvent', () {
    test('should parse json successfully', () {
      var json = events.firstWhere((it) => it['action_topic'] == 'delivered');

      var data = MessageDeliveredEvent.fromJson(json);
      expect(data.messageId, 123);
      expect(data.messageUniqueId, '123--');
      expect(data.roomId, 1234);
      expect(data.userId, 'user-id');
    });
  });

  group('MessageDeletedEvent', () {
    test('should parse json successfully', () {
      var json = events //
          .firstWhere((it) => it['action_topic'] == 'delete_message');

      var data = MessageDeletedEvent.fromJson(json);
      expect(data.first.roomId, 12345);
      expect(data.first.messageUniqueId, '12345');
    });
  });

  group('RoomClearedEvent', () {
    test('should parse json successfully', () {
      var json = events //
          .firstWhere((it) => it['action_topic'] == 'clear_room');

      var data = RoomClearedEvent.fromJson(json);
      expect(data.first.roomId, 123);
    });
  });
}
