class Logger {
  var enabled = false;

//  final _logger = l.Logger();

  void log(String str) {
    if (enabled) print(str);
  }

  void debug(dynamic data) {
    if (enabled) print(data);
  }
}
