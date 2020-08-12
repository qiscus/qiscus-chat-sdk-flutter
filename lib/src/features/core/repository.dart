import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import '../../core/core.dart';
import '../../core/utils.dart';
import '../../core/api_request.dart';
import 'api.dart';
import 'entity.dart';

class CoreRepository {
  const CoreRepository({@required this.dio});

  final Dio dio;

  Task<Either<QError, AppConfig>> getConfig() {
    return task(() {
      final request = GetConfigRequest();

      return dio.sendApiRequest(request).then(request.format);
    });
  }
}
