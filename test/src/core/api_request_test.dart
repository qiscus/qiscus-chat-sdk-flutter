import 'package:dio/dio.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:test/test.dart';

void main() {
  test('api request method', () {
    var get = IRequestMethod.get;
    var post = IRequestMethod.post;
    var put = IRequestMethod.put;
    var patch = IRequestMethod.patch;
    var del = IRequestMethod.delete;

    expect(get.asString, 'get');
    expect(post.asString, 'post');
    expect(put.asString, 'put');
    expect(patch.asString, 'patch');
    expect(del.asString, 'delete');
  });

  test('dio2curl', () {
    var options = RequestOptions(
      path: '/path-1',
      method: 'get',
    );

    var res = dio2curl(options);

    expect(res,
        r"curl --request get '/path-1' -H 'content-type: application/json; charset=utf-8'");
  });

  test('dio2curl with baseUrl', () {
    var options = RequestOptions(
      path: 'http://base-url.com/path-1',
      method: 'get',
      baseUrl: 'some-other-base-url.com',
    );

    var res = dio2curl(options);
    var expected = ''
        "curl --request get 'http://base-url.com/path-1'"
        " -H 'content-type: application/json; charset=utf-8'";
    expect(res, expected);
  });

  test('dio2curl with post data', () {
    var options = RequestOptions(
      path: '/path-1',
      method: 'post',
      data: <String, Object?>{
        'value-1': 1,
        'value-2': true,
      },
    );

    var actual = dio2curl(options);
    var expected = ''
        "curl --request post '/path-1'"
        " -H 'content-type: application/json; charset=utf-8'"
        " --data-binary '{value-1: 1, value-2: true}'";

    expect(actual, expected);
  });

  test('dio2curl with query parameters', () {
    var options = RequestOptions(
      path: '/path-1',
      method: 'get',
      queryParameters: <String, Object?>{
        'bool': true,
        'list': [1, 2, 3],
      },
    );

    var actual = dio2curl(options);
    var expected = ''
        "curl --request get '/path-1"
        '?bool=true'
        "&list[]=1&list[]=2&list[]=3'"
        " -H 'content-type: application/json; charset=utf-8'";

    expect(actual, expected);
  });
}
