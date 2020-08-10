import 'dart:convert';

import 'package:dartz/dartz.dart';

import '../../core/core.dart';
import '../../core/utils.dart';
import 'api.dart';
import 'entity.dart';

class CoreRepository {
  const CoreRepository(this._api);

  final CoreApi _api;

  Task<Either<QError, AppConfig>> getConfig() {
    return task(_api.getConfig).rightMap((str) {
      var json = jsonDecode(str) as Map<String, dynamic>;
      var config = AppConfig.fromJson(json['results'] as Map<String, dynamic>);
      return config;
    });
  }
}
