import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/domain/user/user-model.dart';
import 'package:test/test.dart';

void main() {
  test('mqtt getClientId', () async {
    var id = getClientId(millis: 1);
    expect(id, 'flutter_1');

    id = getClientId(userId: 'user-id', millis: 1);
    expect(id, 'flutter_user-id_1');

    id = getClientId(appId: 'app-id', millis: 1);
    expect(id, 'flutter_app-id_1');

    id = getClientId(appId: 'app-id', userId: 'user-id', millis: 1);
    expect(id, 'flutter_app-id_user-id_1');
  });

  test('mqtt getMqttClient', () async {
    var storage = Storage();
    var client = getMqttClient(storage);
    expect(client.clientIdentifier, startsWith('flutter'));

    storage.appId = 'appId';
    client = getMqttClient(storage);
    expect(client.clientIdentifier, startsWith('flutter_appId'));

    storage.currentUser = QAccount(id: 'userId', name: 'user-name');
    client = getMqttClient(storage);
    expect(client.clientIdentifier, startsWith('flutter_appId_userId'));
  });
}
