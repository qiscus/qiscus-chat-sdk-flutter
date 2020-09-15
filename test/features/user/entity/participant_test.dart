import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';
import 'package:test/test.dart';

void main() {
  QParticipant qParticipant;
  Participant participant;

  setUpAll(() {
    qParticipant = QParticipant(
      id: 'some-id',
      name: 'some-name',
      avatarUrl: 'some-avatar-url',
      extras: <String, dynamic>{'key': 'value'},
      lastReadMessageId: 10,
      lastReceivedMessageId: 10,
    );

    participant = Participant(
      id: 'some-id',
      name: some('name'),
      avatarUrl: some('avatar-url'),
      extras: some(
        imap<String, dynamic>(
          <String, dynamic>{
            'key': 'value',
          },
        ),
      ),
      lastReadMessageId: some(10),
      lastReceivedMessageId: some(10),
    );
  });

  test('QParticipant.toString', () {
    var resp = qParticipant.toString();
    var expected = 'QParticipant('
        'id=some-id, '
        'name=some-name, '
        'avatarUrl=some-avatar-url, '
        'lastReadMessageId=10, '
        'lastReceivedMessageId=10, '
        'extras={key: value}'
        ')';

    expect(resp, expected);
  });

  test('QParticipant.asUser', () {
    var user = qParticipant.asUser();

    expect(user.id, 'some-id');
    expect(user.name, 'some-name');
    expect(user.avatarUrl, 'some-avatar-url');
    expect(user.extras.containsKey('key'), true);
    expect(user.extras['key'], 'value');
  });

  test('Participant.fromJson', () {
    var participant = Participant.fromJson(<String, dynamic>{
      'email': 'some-id',
      'username': 'some-name',
      'avatar_url': 'some-avatar-url',
      'last_received_comment_id': '10',
      'last_read_comment_id': '10',
      'extras': <String, dynamic>{'key': 'value'},
    });

    expect(participant.id, 'some-id');
    expect(participant.name, some('some-name'));
    expect(participant.avatarUrl, some('some-avatar-url'));
    expect(participant.lastReceivedMessageId, some(10));
    expect(participant.lastReadMessageId, some(10));
    expect(
      participant.extras,
      some(
        imap<String, dynamic>(
          <String, dynamic>{
            'key': 'value',
          },
        ),
      ),
    );
  });

  test('Participant blank', () {
    var model = Participant(id: 'id');

    expect(model.id, 'id');
    expect(model.name, None<String>());
    expect(model.avatarUrl, None<String>());
    expect(model.extras, None<IMap<String, dynamic>>());
    expect(model.lastReceivedMessageId, None<int>());
    expect(model.lastReadMessageId, None<int>());
  });

  test('Participant.toModel', () {
    var model = participant.toModel();

    expect(model.id, 'some-id');
    expect(model.name, 'name');
    expect(model.avatarUrl, 'avatar-url');
    expect(model.lastReadMessageId, 10);
    expect(model.lastReceivedMessageId, 10);
    expect(model.extras.containsKey('key'), true);
    expect(model.extras['key'], 'value');
  });
}
