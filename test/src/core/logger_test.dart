import 'package:mockito/mockito.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:test/test.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  var storage = MockStorage();
  var logger = Logger(storage);

  test('logger log should not throw', () {
    when(storage.debugEnabled).thenReturn(false);

    expect(() => logger.log('a'), returnsNormally);
    expect(() => logger.debug(''), returnsNormally);

    verify(storage.debugEnabled).called(2);
    verifyNoMoreInteractions(storage);
  });
}
