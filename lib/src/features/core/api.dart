import '../../core/api_request.dart';
import 'entity.dart';

class GetConfigRequest extends IApiRequest<AppConfig> {
  IRequestMethod get method => IRequestMethod.get;
  String get url => 'config';

  AppConfig format(Map<String, dynamic> json) {
    return null;
  }
}
