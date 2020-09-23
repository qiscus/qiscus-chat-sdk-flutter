import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:test/test.dart';

void main() {
  test('usecases.noParams should be the same', () {
    var n1 = NoParams();
    var n2 = NoParams();

    expect(n1, n2);
  });
}
