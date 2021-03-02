import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/realtime.dart';
import 'package:qiscus_chat_sdk/src/type_utils.dart';
import 'package:test/test.dart';

import '../../../utils.dart';
import 'json.dart';

class MockRealtimeService extends Mock implements IRealtimeService {}

void main() {
  Storage storage;
  Interval interval;
  Logger logger;
  Dio dio;
  IRealtimeService service;

  setUp(() {
    dio = MockDio();
    storage = Storage();
    logger = Logger(storage);
    interval = MockInterval();
    service = SyncServiceImpl(
      storage: storage,
      interval: interval,
      logger: logger,
      dio: dio,
    );

    when(interval.interval()).thenAnswer((_) => Stream.value(null));
  });

  test('subscribeMessageRead', () {
    makeTest(dio, eventJson);
    service.subscribeMessageRead(roomId: 1).take(1).listen(expectAsync1((m) {
          expect(m.chatRoomId, Option.some(1234));
          expect(m.sender.flatMap((it) => it.id), Option.some('user-id'));
          expect(m.id, Option.some(123));
          expect(m.uniqueId, Option.some('123--'));
        }, count: 1));
  });

  test('subscribeMessageDelivered', () {
    makeTest(dio, eventJson);
    service
        .subscribeMessageDelivered(roomId: 1)
        .take(1)
        .listen(expectAsync1((m) {
          expect(m.chatRoomId, Option.some(1234));
          expect(m.sender.flatMap((it) => it.id), Option.some('user-id'));
          expect(m.id, Option.some(123));
          expect(m.uniqueId, Option.some('123--'));
        }, count: 1));
  });

  test('subscribeMessageDeleted', () {
    makeTest(dio, eventJson);
    service.subscribeMessageDeleted().take(1).listen(expectAsync1((m) {
          expect(m.sender.flatMap((it) => it.id), Option.none());
          expect(m.id, Option.none());
          expect(m.uniqueId, Option.some('12345'));
          expect(m.chatRoomId, Option.some(12345));
        }, count: 1));
  });

  test('subscribeMessageReceived', () {
    makeTest(dio, syncJson);
    service.subscribeMessageReceived().take(1).listen(expectAsync1((m) {
          expect(m.sender.flatMap((it) => it.id), Option.some('f1@gmail.com'));
          expect(m.id, Option.some(986));
          expect(m.uniqueId, Option.some('CanBeAnything1234321'));
          expect(m.chatRoomId, Option.some(1));
        }, count: 1));
  });

  test('subscribeRoomCleared', () {
    makeTest(dio, eventJson);
    service.subscribeRoomCleared().take(1).listen(expectAsync1((m) {
          expect(m.id, Option.some(123));
        }, count: 1));
  });
}
