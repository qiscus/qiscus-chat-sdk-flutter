import 'package:logger/logger.dart' as L;

class Logger {
  var enabled = false;

  final _logger = L.Logger();

  void log(String str) {
    if (enabled) _logger.i(str);
  }

  void debug(dynamic data) {
    if (enabled) _logger.d(data);
  }
}
