part of qiscus_chat_sdk.core;

typedef Formatter<Output> = Output Function(Json json);

abstract class IApiRequest<T> {
  IApiRequest();

  String get url;
  IRequestMethod get method;
  Json? get body => null;
  Json? get params => null;
  T format(Json json);

  Future<T> call(Dio dio) async {
    return dio.sendApiRequest(this).then((r) => format(r));
  }

  @override
  String toString() {
    var request = this;
    var body = request.body;
    body?.removeWhere((key, dynamic value) => value == null);
    var params = request.params;
    params?.removeWhere((key, dynamic value) => value == null);

    return ('IApiRequest<$T>('
        '  url="$url",'
        '  method=$method'
        '  body="$body"'
        '  params="$params"'
        ')');
  }
}

enum IRequestMethod { get, post, patch, put, delete }

extension XIRequestMethod on IRequestMethod {
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
  Future<Output> sendApiRequest<Output extends Json>(
    IApiRequest<dynamic> req,
  ) async {
    var body = req.body;
    body?.removeWhere((key, dynamic value) => value == null);
    var params = req.params;
    params?.removeWhere((key, dynamic value) => value == null);

    try {
      return request<Output>(
        req.url,
        options: Options(
          method: req.method.asString,
          listFormat: ListFormat.multiCompatible,
          contentType: req.method == IRequestMethod.delete
              ? ContentType.text.mimeType
              : null,
        ),
        data: body?.isNotEmpty == true ? body : null,
        queryParameters: params?.isNotEmpty == true ? params : null,
      ).then((it) => it.data!);
    } catch (e) {
      if (e is DioError) {
        print(e.response?.data.toString());
      }
      rethrow;
    }
  }
}
