import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/account.dart';
import 'package:test/test.dart';

void main() {
  QAccount qAccount;
  Account account;

  setUpAll(() {
    qAccount = QAccount(
      id: 'some-id',
      avatarUrl: 'some-avatar-url',
      extras: <String, dynamic>{
        'key': 'value',
      },
      name: 'some-name',
      lastEventId: 10,
      lastMessageId: 10,
    );

    account = Account(
      id: 'some-id',
      name: some('some-name'),
      avatarUrl: some('some-avatar-url'),
      extras: some(imap<String, dynamic>(<String, dynamic>{'key': 'value'})),
      lastEventId: some(10),
      lastMessageId: some(10),
    );
  });

  test('QAccount.toString', () {
    var str = qAccount.toString();
    var expectedValue =
        'QAccount(id=some-id, name=some-name, avatarUrl=some-avatar-url, lastMessageId=10, lastEventId=10, extras={key: value})';

    expect(str, expectedValue);
  });

  test('QAccount.asUser', () {
    var user = qAccount.asUser();

    expect(user.id, 'some-id');
    expect(user.name, 'some-name');
    expect(user.avatarUrl, 'some-avatar-url');
    expect(user.extras['key'], 'value');
  });

  test('Account.copy', () {
    var resp = account.copy(
      name: some('updated-name'),
    );

    expect(resp.name, some('updated-name'));
    expect(resp.id, 'some-id');
    expect(resp.avatarUrl, some('some-avatar-url'));
    expect(
      resp.extras,
      some(
        imap<String, dynamic>(
          <String, dynamic>{'key': 'value'},
        ),
      ),
    );
    expect(resp.lastEventId, some(10));
    expect(resp.lastMessageId, some(10));
  });

  test('Account.toModel', () {
    var model = account.toModel();

    expect(model.id, 'some-id');
    expect(model.name, 'some-name');
    expect(model.avatarUrl, 'some-avatar-url');
    expect(model.extras['key'], 'value');
    expect(model.lastEventId, 10);
    expect(model.lastMessageId, 10);
  });
}
