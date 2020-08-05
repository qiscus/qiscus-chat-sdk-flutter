import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';
import 'package:test/test.dart';

void main() {
  QUser qUser;
  User user;

  setUpAll(() {
    qUser = QUser(
      id: 'some-id',
      name: 'some-name',
      avatarUrl: 'some-avatar-url',
      extras: <String, dynamic>{
        'key': 'value',
      },
    );
    user = User(
      id: 'some-id'.toOption(),
      name: some('name'),
      avatarUrl: some('avatar-url'),
      extras: some<IMap<String, dynamic>>(
        imap<String, dynamic>(
          <String, dynamic>{'key': 'value'},
        ),
      ),
    );
  });

  test('QUser.toString', () {
    var resp = qUser.toString();
    var expectedValue =
        'QUser(id=some-id, name=some-name, avatarUrl=some-avatar-url, extras={key: value})';

    expect(resp, expectedValue);
  });

  test('User.asModel', () {
    var uss = user.toModel();

    expect(uss.id, 'some-id');
    expect(uss.name, 'name');
    expect(uss.avatarUrl, 'avatar-url');
    expect(uss.extras.containsKey('key'), true);
    expect(uss.extras['key'], 'value');
  });

  test('User.fromJson', () {
    var user = User.fromJson(<String, dynamic>{
      'email': 'user-id',
      'username': 'some-name',
      'avatar_url': 'some-avatar-url',
      'extras': <String, dynamic>{'key': 'value'},
    });

    expect(user.id, 'user-id');
    expect(user.name, some('some-name'));
    expect(user.avatarUrl, some('some-avatar-url'));
    expect(
      user.extras,
      some(
        imap<String, dynamic>(
          <String, dynamic>{
            'key': 'value',
          },
        ),
      ),
    );
  });
}
