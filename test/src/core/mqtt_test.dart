import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';
import 'package:test/test.dart';

void main() {
  test('create mqtt instance', () async {
    var storage = Storage();
    storage.appId = 'app-id';
    storage.token = 'token';
    storage.currentUser = Account(id: 'user-id');

    getMqttClient(storage);
  });

  test('create correct clientId', () {
    var clientId = getClientId(10);

    expect(clientId, 'dart-sdk-10');
  });

  test('create correct connection message', () {
    var cm = getConnectionMessage('client-id', 'user-id');

    expect(cm.payload.clientIdentifier, 'client-id');
    expect(cm.payload.willTopic, 'u/user-id/s');
    expect(cm.payload.willMessage, '0');
  });
}
