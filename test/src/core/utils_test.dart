import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:test/test.dart';

void main() {
  test('utils decodeJson with an empty map', () {
    var res = decodeJson(<String, Object?>{});

    expect(res, None<Map<String, Object?>>());
  });

  test('utils decodeJson with a map', () {
    var res = decodeJson({'status': true});

    expect(res.map((v) => v['status']), Some(true));
  });

  test('utils decodeJson with empty string', () {
    var res = decodeJson('');

    expect(res, None<Map<String, Object?>>());
  });

  test('utils decodeJson with a string json', () {
    var res = decodeJson('{"status": true}');

    expect(res.map((v) => v['status']), Some(true));
  });

  test('utils decodeJson with non map or string', () {
    var res = decodeJson(123);

    expect(res, None<Map<String, Object?>>());
  });

  test('utils decodeJson with throwing string', () {
    var res = decodeJson('{abc: 123}');
    expect(res, None<Map<String, Object?>>());
  });
}
