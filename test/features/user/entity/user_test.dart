import 'package:qiscus_chat_sdk/src/user/user.dart';
import 'package:qiscus_chat_sdk/src/type-utils.dart';
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
      id: Option.some('some-id'),
      name: Option.some('name'),
      avatarUrl: Option.some('avatar-url'),
      extras: Option.some(
        <String, dynamic>{'key': 'value'},
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

    expect(user.id, Option.some('user-id'));
    expect(user.name, Option.some('some-name'));
    expect(user.avatarUrl, Option.some('some-avatar-url'));
    expect(
      user.extras,
      Option.some(
        <String, dynamic>{
          'key': 'value',
        },
      ),
    );
  });
}

class IMap {}
