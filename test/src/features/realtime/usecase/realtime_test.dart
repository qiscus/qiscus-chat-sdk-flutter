import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/realtime/realtime.dart';
import 'package:test/test.dart';

class MockService extends Mock implements IRealtimeService {}

void main() {
  IRealtimeService service;
  OnConnected onConnected;
  OnReconnecting onReconnecting;
  OnDisconnected onDisconnected;

  setUpAll(() {
    service = MockService();
    onConnected = OnConnected(service);
    onReconnecting = OnReconnecting(service);
    onDisconnected = OnDisconnected(service);
  });

  test('OnConnected.subscribe', () async {
    when(service.onConnected()).thenAnswer((_) => Stream.value(null));

    onConnected.subscribe(noParams);

    verify(service.onConnected()).called(1);
    verifyNoMoreInteractions(service);
  });
  test('OnReconnecting.subscribe', () async {
    when(service.onReconnecting()).thenAnswer((_) => Stream.value(null));

    onReconnecting.subscribe(noParams);

    verify(service.onReconnecting()).called(1);
    verifyNoMoreInteractions(service);
  });
  test('OnConnected.subscribe', () async {
    when(service.onDisconnected()).thenAnswer((_) => Stream.value(null));

    onDisconnected.subscribe(noParams);

    verify(service.onDisconnected()).called(1);
    verifyNoMoreInteractions(service);
  });
}
