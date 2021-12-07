import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/user/user.dart';
import 'package:test/test.dart';

void main() {
  Storage storage;

  setUp(() {
    storage = Storage();
  });

  tearDown(() {
    storage.clear();
  });

  test('StorageX', () async {
    storage.currentUser = Account(id: 'user-id');

    expect(StorageX(storage).authenticated$, completion(true));
  }, timeout: Timeout(Duration(seconds: 2)));
}
