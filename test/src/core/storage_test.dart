import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/domains.dart';
import 'package:test/test.dart';

void main() {
  test('storage test', () {
    var s1 = Storage();
    var s2 = Storage();

    expect(s1, equals(s2));

    s2.appId = 'something';
    expect(s1, isNot(equals(s2)));
  });

  test('storage.clear test', () {
    var s1 = Storage(token: 'token');
    expect(s1.token, 'token');
    s1.clear();
    expect(s1.token, isNull);
  });

  test('storage.userId', () {
    var account = QAccount(id: 'user-id', name: 'user-name');
    var s1 = Storage(currentUser: account);

    expect(s1.userId, 'user-id');
  });
}
