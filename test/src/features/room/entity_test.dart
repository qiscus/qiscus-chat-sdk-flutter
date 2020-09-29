import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/features/room/room.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';
import 'package:test/test.dart';

void main() {
  QChatRoom qroom;
  ChatRoom room;

  setUp(() {
    qroom = QChatRoom(
      id: 123,
      name: 'name',
      uniqueId: 'unique-id',
      unreadCount: 2,
      avatarUrl: 'avatar-url',
      totalParticipants: 0,
      extras: <String, dynamic>{},
      participants: <QParticipant>[],
      lastMessage: null,
      type: QRoomType.single,
    );

    room = ChatRoom(
      id: some(123),
      uniqueId: some('unique-id'),
      avatarUrl: some('avatar-url'),
      extras: some(imap<String, dynamic>(<String, dynamic>{ 'key': 'value' })),
      lastMessage: none(),
      name: some('name'),
      participants: none(),
      totalParticipants: none(),
      type: some(QRoomType.channel),
      unreadCount: some(1),
    );
  });

  test('QChatRoom.toString', () {
    var str = qroom.toString();
    var expected = 'QChatRoom('
        'id=123, '
        'name=name, '
        'uniqueId=unique-id, '
        'unreadCount=2, '
        'avatarUrl=avatar-url, '
        'totalParticipants=0, '
        'extras={}, '
        'participants=[], '
        'lastMessage=null, '
        'type=QRoomType.single'
        ')';

    expect(str, expected);
  });

  test('ChatRoom.toModel()', () {
    var model = room.toModel();

    expect(model.name, 'name');
    expect(model.extras.keys.length, 1);
    expect(model.extras['key'], 'value');
    expect(model.id, 123);
    expect(model.lastMessage, null);
    expect(model.uniqueId, 'unique-id');
    expect(model.avatarUrl, 'avatar-url');
    expect(model.participants.length, 0);
    expect(model.totalParticipants, 0);
    expect(model.type, QRoomType.channel);
    expect(model.unreadCount, 1);
  });
}
