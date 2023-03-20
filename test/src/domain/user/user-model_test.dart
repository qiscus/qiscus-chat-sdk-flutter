import 'package:qiscus_chat_sdk/src/domain/user/user-model.dart';
import 'package:test/test.dart';

void main() {
  test('QUser.', () {
    var user1 = QUser(id: 'user-id1', name: 'user-name1');
    var user2 = QUser(id: 'user-id2', name: 'user-name2');
    var user3 = QUser(id: 'user-id1', name: 'user-name1');

    expect(user1, equals(user3));
    expect(user1, isNot(user2));
  });

  test('QAccount', () {
    var account1 = QAccount(id: 'user-id1', name: 'username1');
    var account2 = QAccount(id: 'user-id2', name: 'username2');
    var account3 = QAccount(id: 'user-id1', name: 'username1');

    expect(account1, equals(account3));
    expect(account1, isNot(equals(account2)));
  });

  test('QParticipant', () {
    var user1 = QParticipant(id: 'user-id1', name: 'username1');
    var user2 = QParticipant(id: 'user-id2', name: 'username2');
    var user3 = QParticipant(id: 'user-id1', name: 'username1');

    expect(user1, equals(user3));
    expect(user1, isNot(equals(user2)));
  });

  test('QUserTyping', () {
    var user1 = QUserTyping(userId: 'user-id1', roomId: 1, isTyping: true);
    var user2 = QUserTyping(userId: 'user-id2', roomId: 1, isTyping: true);
    var user3 = QUserTyping(userId: 'user-id1', roomId: 1, isTyping: true);

    expect(user1, equals(user3));
    expect(user1, isNot(equals(user2)));
  });

  test('QUserPresence', () {
    var user1 = QUserPresence(
        userId: 'user-id1', lastSeen: DateTime.now(), isOnline: true);
    var user2 = QUserPresence(
        userId: 'user-id2', lastSeen: DateTime.now(), isOnline: true);
    var user3 = QUserPresence(
        userId: 'user-id1', lastSeen: DateTime.now(), isOnline: true);

    expect(user1, equals(user3));
    expect(user1, isNot(equals(user2)));
  });
}
