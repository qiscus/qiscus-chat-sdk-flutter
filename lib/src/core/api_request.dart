part of qiscus_chat_sdk.core;

typedef Formatter<Output> = Output Function(Map<String, dynamic> json);

abstract class IApiRequest<T> {
  String get url;

  IRequestMethod get method;

  Map<String, dynamic> get body => <String, dynamic>{};

  Map<String, dynamic> get params => <String, dynamic>{};

  T format(Map<String, dynamic> json);

  Future<T> call(Dio dio) async {
    return dio.sendApiRequest(this).then((r) => format(r));
  }
}

enum IRequestMethod { get, post, patch, put, delete }

extension on IRequestMethod {
  String get asString {
    switch (this) {
      case IRequestMethod.get:
        return 'get';
      case IRequestMethod.post:
        return 'post';
      case IRequestMethod.patch:
        return 'patch';
      case IRequestMethod.put:
        return 'put';
      case IRequestMethod.delete:
        return 'delete';
      default:
        return 'get';
    }
  }
}

extension DioXRequest on Dio {
  Future<Output> call<Output>(
    IApiRequest<Output> r,
  ) async {
    var body = (r.body ?? <String, dynamic>{})
      ..removeWhere((_, dynamic v) => v == null);
    var params = (r.params ?? <String, dynamic>{})
      ..removeWhere((_, dynamic v) => v == null);

    return request<Map<String, dynamic>>(
      r.url,
      options: Options(method: r.method.asString),
      data: body,
      queryParameters: params,
    ).then((it) => it.data).then((it) => r.format(it));
  }

  Future<Output> sendApiRequest<Output extends Map<String, dynamic>>(
    IApiRequest request,
  ) async {
    var body = (request.body ?? <String, dynamic>{})
      ..removeWhere((key, dynamic value) => value == null);
    var params = (request.params ?? <String, dynamic>{})
      ..removeWhere((key, dynamic value) => value == null);

    return this
        .request<Output>(
          request.url,
          options: Options(method: request.method.asString),
          data: body,
          queryParameters: params,
        )
        .then((it) => it.data);
  }
}
