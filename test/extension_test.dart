import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

class MockQiscus extends Mock implements QiscusSDK {}

void main() {
  QiscusSDK qiscus;

  setUpAll(() {
    qiscus = MockQiscus();
  });

  test('setUser\$', () async {
    var extras = <String, dynamic>{'key': 'value'};

    when(qiscus.setUser(
      userId: anyNamed('userId'),
      userKey: anyNamed('userKey'),
      callback: anyNamed('callback'),
      avatarUrl: anyNamed('avatarUrl'),
      extras: anyNamed('extras'),
      username: anyNamed('username'),
    )).thenAnswer((_) => Future.value(null));

    await XQiscusSDK(qiscus).setUser$(
      userId: 'user-id',
      userKey: 'user-key',
      extras: extras,
      avatarUrl: 'avatar-url',
      username: 'username',
    );

    verify(qiscus.setUser(
      callback: (_, err) => fail(err.message),
      userId: 'user-id',
      userKey: 'user-key',
      extras: extras,
      avatarUrl: 'avatar-url',
      username: 'username',
    )).called(1);
    verifyNoMoreInteractions(qiscus);
  }, skip: true);
}
