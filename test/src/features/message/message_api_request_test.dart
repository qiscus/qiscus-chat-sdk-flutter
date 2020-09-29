import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/features/message/message.dart';
import 'package:test/test.dart';

void main() {
  group('SendMessageRequest', () {
    var request = SendMessageRequest(
      message: 'message',
      roomId: 1,
    );
    test('body', () {
      expect(request.url, 'post_comment');
      expect(request.method, IRequestMethod.post);
    });
    test('format', () {});
  });
}
