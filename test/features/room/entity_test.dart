import 'package:qiscus_chat_sdk/qiscus_chat_sdk.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';
import 'package:test/test.dart';

void main() {
  QChatRoom room;

  setUpAll(() {
    room = QChatRoom(
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
  });

  test('QChatRoom.toString', () {
    var str = room.toString();
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
}
