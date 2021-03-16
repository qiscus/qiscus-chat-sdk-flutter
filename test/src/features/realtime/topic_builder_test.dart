import 'package:qiscus_chat_sdk/src/realtime/realtime.dart';
import 'package:test/test.dart';

void main() {
  test('TopicBuilder.messageNew()', () {
    var topic = TopicBuilder.messageNew('token');
    expect(topic, 'token/c');
  });

  test('TopicBuilder.typing()', () {
    var topic = TopicBuilder.typing('1', 'user-id');
    expect(topic, 'r/1/1/user-id/t');
  });

  test('TopicBuilder.presence()', () {
    var topic = TopicBuilder.presence('user-id');
    expect(topic, 'u/user-id/s');
  });
  test('TopicBuilder.messageDelivered()', () {
    var topic = TopicBuilder.messageDelivered('room-id');
    expect(topic, 'r/room-id/+/+/d');
  });
  test('TopicBuilder.notification()', () {
    final topic = TopicBuilder.notification('token');
    expect(topic, 'token/n');
  });
  test('TopicBuilder.messageRead()', () {
    final topic = TopicBuilder.messageRead('room-id');
    expect(topic, 'r/room-id/+/+/r');
  });
  test('TopicBuilder.channelMessageNew()', () {
    final topic = TopicBuilder.channelMessageNew('app-id', 'channel-id');
    expect(topic, 'app-id/channel-id/c');
  });
  test('TopicBuilder.customEvent()', () {
    final topic = TopicBuilder.customEvent(1);
    expect(topic, 'r/1/1/e');
  });
}
