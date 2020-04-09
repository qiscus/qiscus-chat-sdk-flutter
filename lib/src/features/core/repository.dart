import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';

import 'api.dart';
import 'entity.dart';

abstract class CoreRepository {
  Task<Either<Exception, AppConfig>> getConfig();
}

class CoreRepositoryImpl implements CoreRepository {
  const CoreRepositoryImpl(this._api);

  final CoreApi _api;

  @override
  Task<Either<Exception, AppConfig>> getConfig() {
    return Task(() => _api.getConfig())
        .attempt()
        .leftMapToException()
        .rightMap((str) {
      var json = jsonDecode(str)['results'];
      var config = AppConfig.fromJson(json);
      return config;
    });
  }
}
