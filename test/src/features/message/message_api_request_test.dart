import 'package:qiscus_chat_sdk/src/features/message/message.dart';
import 'package:test/test.dart';

void main() {
  group('SendMessageRequest', () {
    var request = SendMessageRequest(
      message: 'message',
      roomId: 1,
    );
    test('body', () {});
    test('format', () {});
  });
}
