import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/features/message/message.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/realtime.dart';
import 'package:qiscus_chat_sdk/src/type_utils.dart';
import 'package:test/test.dart';

class MockService extends Mock implements IRealtimeService {}

class MockUpdateStatus extends Mock implements UpdateMessageStatusUseCase {}

void main() {
  IRealtimeService mockService;

  setUp(() {
    mockService = MockService();
  });

  group('RoomIdParams', () {
    test('equal', () {
      var a1 = RoomIdParams(1);
      var a2 = RoomIdParams(1);
      var b1 = RoomIdParams(2);

      expect(a1, a2);
      expect(a1, isNot(b1));
    });
    test('stringify', () {
      var a1 = RoomIdParams(1);
      expect(a1.toString(), 'RoomIdParams(1)');
    });
  });

  group('RoomUniqueIdParams', () {
    test('equal', () {
      var a1 = RoomUniqueIdsParams('unique-id');
      var a2 = RoomUniqueIdsParams('unique-id');
      var b1 = RoomUniqueIdsParams('unique-id-a');

      expect(a1, a2);
      expect(a1, isNot(b1));
    });

    test('stringify', () {
      var a1 = RoomUniqueIdsParams('unique-id');

      expect(a1.toString(), 'RoomUniqueIdsParams(unique-id)');
    });
  });
  group('TokenParams', () {
    test('equal', () {
      var a1 = TokenParams('token');
      var a2 = TokenParams('token');
      var b1 = TokenParams('token-a');

      expect(a1, a2);
      expect(a1, isNot(b1));
    });

    test('stringify', () {
      var a1 = TokenParams('token');

      expect(a1.toString(), 'TokenParams(token)');
    });
  });

  group('OnMessageDeleted', () {
    OnMessageDeleted s;

    setUp(() {
      s = OnMessageDeleted(mockService);
    });

    test('.subscribe()', () async {
      var params = TokenParams('token');

      when(mockService.subscribeMessageDeleted()).thenAnswer(
          (_) => Stream<Message>.periodic(1.milliseconds).map((_) => Message(
                id: Option.some(1),
              )));

      var stream = s.subscribe(params);
      stream.take(1).listen(expectAsync1((data) {
        expect(data.id, Option.some(1));
      }));
    });
  });

  group('OnMessageRead', () {
    OnMessageRead s;

    setUp(() {
      s = OnMessageRead(mockService);
    });

    test('.subscribe()', () async {
      when(mockService.subscribeMessageRead(roomId: anyNamed('roomId')))
          .thenAnswer((_) {
        return Stream<Message>.periodic(1.milliseconds).map((_) {
          return Message(id: Option.some(1));
        });
      });

      var stream = s.subscribe(RoomIdParams(1));
      stream.take(1).listen(expectAsync1((data) {
        expect(data.id, Option.some(1));
      }));
    });
  });

  group('OnMessageDelivered', () {
    OnMessageDelivered s;

    setUp(() {
      s = OnMessageDelivered(mockService);
    });

    test('.subscribe', () async {
      when(mockService.subscribeMessageDelivered(roomId: anyNamed('roomId')))
          .thenAnswer((_) {
        return Stream<Message>.periodic(1.milliseconds).map((_) {
          return Message(id: Option.some(1), chatRoomId: Option.some(1));
        });
      });

      var stream = s.subscribe(RoomIdParams(1));
      stream.take(1).listen(expectAsync1((data) {
        expect(data.id, Option.some(1));
      }));
    });
  });

  group('OnMessageReceived', () {
    OnMessageReceived s;
    UpdateMessageStatusUseCase updateMessageUseCase;

    setUp(() {
      updateMessageUseCase = MockUpdateStatus();
      s = OnMessageReceived(mockService, updateMessageUseCase);
    });

    test('.subscribe', () async {
      when(mockService.subscribeMessageReceived()).thenAnswer((_) {
        return Stream<Message>.periodic(1.milliseconds).map((_) {
          return Message(id: Option.some(1));
        });
      });

      when(updateMessageUseCase.call(any))
          .thenAnswer((_) => Future.value(null));

      var stream = s.subscribe(TokenParams('some-token'));
      stream.take(1).listen(expectAsync1((data) {
        expect(data.id, Option.some(1));
      }));
    });
    test('.subscribe with roomId', () async {
      when(mockService.subscribeMessageReceived()).thenAnswer((_) {
        return Stream<Message>.periodic(1.milliseconds).map((_) {
          return Message(id: Option.some(1), chatRoomId: Option.some(1));
        });
      });

      when(updateMessageUseCase.call(any))
          .thenAnswer((_) => Future.value(null));

      var stream = s.subscribe(TokenParams('some-token'));
      stream.take(1).listen(expectAsync1((data) {
        expect(data.id, Option.some(1));
      }));
    });
  });
}
