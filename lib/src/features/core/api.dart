import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'api.g.dart';

@RestApi(autoCastResponse: false)
abstract class CoreApi {
  factory CoreApi(Dio dio) = _CoreApi;

  @GET('config')
  Future<String> getConfig();
}
