import 'package:qiscus_chat_sdk/src/features/message/message.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/realtime.dart';
import 'package:qiscus_chat_sdk/src/features/room/room.dart';
import 'package:qiscus_chat_sdk/src/type_utils.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

class MockService extends Mock implements IRealtimeService {}

void main() {
  IRealtimeService service;
  OnRoomMessagesCleared useCase;

  setUp(() {
    service = MockService();
    useCase = OnRoomMessagesCleared(service);
  });

  test('OnRoomMessagesCleared.subscribe', () async {
    when(service.subscribe(any)).thenAnswer((_) => Future.value(null));
    when(service.subscribeRoomCleared()).thenAnswer((_) => Stream.periodic(
          const Duration(milliseconds: 1),
          (_) => ChatRoom(
            id: Option.some(1),
            name: Option.some('name'),
          ),
        ));

    var stream = await useCase.subscribe(TokenParams('token'));

    stream.take(1).listen(expectAsync1((roomId) {
          expect(roomId, Option.some(1));
        }, max: 1));

    // verify(service.subscribe(TopicBuilder.notification('token'))).called(1);
    // verify(service.subscribeRoomCleared()).called(1);
    // verifyNoMoreInteractions(service);
  });
}
