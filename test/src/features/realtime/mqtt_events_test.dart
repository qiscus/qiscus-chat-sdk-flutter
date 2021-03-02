import 'dart:convert';

import 'package:qiscus_chat_sdk/src/realtime/realtime.dart';
import 'package:qiscus_chat_sdk/src/type_utils.dart';
import 'package:test/test.dart';

void main() {
  group('MqttTypingEvent', () {
    MqttUserTyping event;
    setUp(() {
      event = MqttUserTyping(roomId: '0', userId: '123', isTyping: true);
    });
    test('topic', () {
      expect(event.topic, 'r/0/0/123/t');
    });
    test('publish', () {
      var r = event.publish();
      expect(r, '1');
    });
    test('receive', () {
      var data = event.receive(Tuple2(event.topic, '1'));
      data.listen(expectAsync1((d) {
        expect(d.roomId, 0);
        expect(d.userId, '123');
        expect(d.isTyping, true);
      }, count: 1));
    });
  });

  group('MqttCustomEvent', () {
    MqttCustomEvent event;

    setUp(() {
      event = MqttCustomEvent(
        roomId: 1,
        payload: <String, dynamic>{'name': 123},
      );
    });

    test('topic', () => expect(event.topic, 'r/1/1/e'));
    test('publish', () {
      var r = event.publish();
      expect(r, '{"name":123}');
    });
    test('receive', () {
      var data = event.receive(Tuple2(event.topic, '{ "name": "uddin" }'));
      data.listen(expectAsync1((data) {
        expect(data.roomId, 1);
        expect(data.payload['name'], 'uddin');
      }, count: 1));
    });
  });

  group('MqttPresenceEvent', () {
    MqttUserPresence event;
    DateTime lastSeen;
    String payload;

    setUp(() {
      lastSeen = DateTime.now();
      payload = '1:${lastSeen.millisecondsSinceEpoch}';
      event = MqttUserPresence(
        userId: '123',
        isOnline: true,
        lastSeen: lastSeen,
      );
    });

    test('topic', () => expect(event.topic, 'u/123/s'));
    test('publish', () {
      var d = event.publish();
      expect(d, payload);
    });
    test('receive', () {
      var r = event.receive(Tuple2(event.topic, payload));
      r.listen(expectAsync1((data) {
        expect(data.isOnline, true);
        expect(data.lastSeen.millisecondsSinceEpoch,
            lastSeen.millisecondsSinceEpoch);
        expect(data.userId, '123');
      }, count: 1));
    });
  });

  group('MqttMessageReceivedEvent', () {
    MqttMessageReceived event;

    setUp(() {
      event = MqttMessageReceived(token: 'ini-token');
    });

    test('topic', () => expect(event.topic, 'ini-token/c'));
    test('receive', () {
      var json = <String, dynamic>{
        'id': 3326,
        'comment_before_id': 2920,
        'message': 'Halo',
        'username': 'Zetra',
        'email': 'zetra1@gmail.com',
        'user_avatar':
            'https://qiscuss3.s3.amazonaws.com/uploads/d8cf89cba2be4953bcbb471778263e86/2.png',
        'timestamp': '2016-10-28T08:23:03Z',
        'unix_timestamp': 123456789,
        'created_at': '2016-10-28T08:23:03.074Z',
        'room_id': 207,
        'room_name': 'room name',
        'topic_id': 207,
        'unique_temp_id': 'android_1477642981693c5458b0531df164',
        'disable_link_preview': false,
        'chat_type': 'group'
      };
      var r = event.receive(Tuple2(event.topic, jsonEncode(json)));
      r.listen(expectAsync1((data) {
        expect(data.id, Option.some(3326));
        expect(data.text, Option.some('Halo'));
        expect(data.sender.flatMap((it) => it.id),
            Option.some('zetra1@gmail.com'));
      }, count: 1));
    });
  });

  group('MqttMessageReadEvent', () {
    MqttMessageRead event;

    setUp(() {
      event = MqttMessageRead(roomId: '1');
    });

    test('topic', () => expect(event.topic, 'r/1/+/+/r'));

    test('receive', () {});
  });
}
