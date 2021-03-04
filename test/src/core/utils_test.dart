import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/type_utils.dart';
import 'package:test/test.dart';

void main() {
  test('utils.streamify', () async {
    var stream = streamify<int>((callback, done) {
      List.generate(5, (index) => index).forEach((id) => callback(id));

      done();

      return () {};
    });

    expect(
        stream,
        emitsInOrder(<Matcher>[
          emits(0),
          emits(1),
          emits(2),
          emits(3),
          emits(4),
          emitsDone,
        ]));
  }, timeout: Timeout(Duration(seconds: 2)));

  group('utils.futurify', () {
    test('utils.futurify1 success', () async {
      var future = futurify1((cb) {
        cb(null);
      });
      expect(future, completion(equals(null)));
    });
    test('utils.futurify1 failure', () async {
      expect(futurify1((cb) {
        cb(Exception('message'));
      }), throwsA(isA<Exception>()));
    });

    test('utils.futurify2 success', () {
      var future = futurify2<int>((cb) {
        cb(123, null);
      });

      expect(future, completion(equals(123)));
    });

    test('utils.futurify2 failure', () {
      var future = futurify2<int>((cb) {
        cb(null, Exception('message'));
      });

      expect(future, throwsA(isA<Exception>()));
    });
  });

  group('utils.decodeJson', () {
    test('empty map', () {
      var map = <String, dynamic>{};

      var result = decodeJson(map);

      expect(Option.isNone(result), true);
    });

    test('empty string', () {
      var str = '';
      var result = decodeJson(str);

      expect(Option.isNone(result), true);
    });

    test('non empty invalid json string', () {
      var str = 'datesomething';
      var result = decodeJson(str);
      expect(Option.isNone(result), true);
    });

    test('non empty valid json string', () {
      var str = '{ "key": "value" }';
      var result = decodeJson(str);

      result.fold(() => fail('should not be none'), (data) {
        expect(data.keys.length, 1);
        expect(data['key'], 'value');
      });
    });

    test('null containing string', () {
      var str = 'null';
      var result = decodeJson(str);

      expect(Option.isSome(result), true);
    });

    test('neither map / string', () {
      var data = 120;
      var result = decodeJson(data);

      expect(Option.isNone(result), true);
    });

    test('non empty map', () {
      var data = {'key': 'value'};
      var result = decodeJson(data);

      result.fold(() => fail('should not be none'), (r) {
        expect(r['key'], 'value');
        expect(r.keys.length, 1);
      });
    });
  }, timeout: Timeout(Duration(seconds: 1)));
}
