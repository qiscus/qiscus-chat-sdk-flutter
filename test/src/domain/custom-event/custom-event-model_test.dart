import 'package:qiscus_chat_sdk/src/domain/custom-event/custom-event-model.dart';
import 'package:test/test.dart';

void main() {
  test('QCustomEvent', () {
    var data1 = QCustomEvent(roomId: 1, payload: {'val1': 1});
    var data2 = QCustomEvent(roomId: 1, payload: {'val1': 1});
    var data3 = QCustomEvent(roomId: 1, payload: {'val2': 1});

    expect(data1, data2);
    expect(data1, isNot(data3));
  });
}
