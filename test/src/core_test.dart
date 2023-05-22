import 'package:test/test.dart';
import 'package:qiscus_chat_sdk/src/core.dart';

void main() {
  const userId1 = 'user-id';
  const userId2 = 'some-unique_user-id@maili.com';
  const roomId = 123;

  test('new message regex', () {
    var t1 = reNewMessage.hasMatch('some-token/c');
  });
}
