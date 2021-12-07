import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/message/message.dart';
import 'package:qiscus_chat_sdk/src/realtime/realtime.dart';
import 'package:qiscus_chat_sdk/src/type-utils.dart';
import 'package:test/test.dart';
import '../realtime/json.dart';

void main() {
  group('SynchronizeRequest', () {
    SynchronizeRequest request;

    setUp(() {
      request = SynchronizeRequest();
    });

    test('body', () {
      expect(request.url, 'sync');
      expect(request.method, IRequestMethod.get);
      expect(request.params.keys.length, 1);
      expect(request.params['last_received_comment_id'], 0);
    });

    test('format', () {
      var json = syncJson;

      var resp = request.format(json);

      expect(resp.first, 986);
      expect(resp.second.first.id, Option.some(986));
      expect(resp.second.first.chatRoomId, Option.some(1));
      expect(resp.second.first.text, Option.some('Hello Post 2'));
      expect(resp.second.first.type, Option.some(QMessageType.text));
    });
  });

  group('SynchronizeEventRequest', () {
    SynchronizeEventRequest request;

    setUp(() {
      request = SynchronizeEventRequest();
    });

    test('body', () {
      expect(request.url, 'sync_event');
      expect(request.method, IRequestMethod.get);
      expect(request.params.length, 1);
      expect(request.params['start_event_id'], 0);
    });

    test('format', () {
      var json = eventJson;
      var resp = request.format(json);

      var readEvent = resp.second.whereType<MessageReadEvent>();
      var deliveredEvent = resp.second.whereType<MessageDeliveredEvent>();
      var roomClearedEvent = resp.second.whereType<RoomClearedEvent>();
      var deletedEvent = resp.second.whereType<MessageDeletedEvent>();

      expect(resp.first, 4);

      expect(readEvent.length, 1);
      expect(readEvent.first.messageId, 123);

      expect(deliveredEvent.length, 1);
      expect(deliveredEvent.first.messageId, 123);

      expect(roomClearedEvent.length, 1);
      expect(roomClearedEvent.first.messageId, 123);

      expect(deletedEvent.length, 1);
      expect(deletedEvent.first.messageUniqueId, '12345');
    });
  });
}
