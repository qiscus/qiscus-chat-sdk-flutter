import 'package:qiscus_chat_sdk/src/domain/room/room-model.dart';
import 'package:test/test.dart';

void main() {
  test('QChatRoom', () {
    var room1 = QChatRoom(id: 1, uniqueId: '1', name: 'name1');
    var room2 = QChatRoom(id: 2, uniqueId: '2', name: 'name2');
    var room3 = QChatRoom(id: 1, uniqueId: '1', name: 'name1');

    expect(room1, equals(room3));
    expect(room1, isNot(equals(room2)));
  });

  test('QChatRoom.toString', () {
    var room1 = QChatRoom(id: 1, uniqueId: '1', name: 'name1');

    var actual = room1.toString();
    var expected = 'QChatRoom('
        'id=1, '
        'name=name1, '
        'uniqueId=1, '
        'unreadCount=0, '
        'avatarUrl=null, '
        'totalParticipants=0, '
        'extras=null, '
        'participants=[], '
        'lastMessage=null, '
        'type=QRoomType.single)';

    expect(actual, expected);
  });
}
