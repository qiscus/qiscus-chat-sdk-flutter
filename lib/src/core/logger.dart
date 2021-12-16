part of qiscus_chat_sdk.core;

enum QLogLevel {
  verbose,
  log,
  debug,
}

class Logger {
  const Logger(this.storage);

  final Storage storage;

  QLogLevel get level => storage.logLevel;
  bool get enabled => storage.debugEnabled;
  String get _appId => storage.appId;

  void log(String str) {
    if (enabled) print('QiscusSDK[$_appId] -- $str');
  }

  void debug(dynamic data) {
    if (enabled) print('QiscusSDK[$_appId] -- $data');
  }
}
