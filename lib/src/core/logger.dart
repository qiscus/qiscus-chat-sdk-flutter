import 'package:qiscus_chat_sdk/src/core/core.dart';

class Logger {
  const Logger(this.storage);
  final Storage storage;

  bool get enabled => storage.debugEnabled;

  void log(String str) {
    if (enabled) print(str);
  }

  void debug(dynamic data) {
    if (enabled) print(data);
  }
}
