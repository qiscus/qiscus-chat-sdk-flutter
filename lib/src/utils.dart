import 'dart:async';

import 'package:riverpod/riverpod.dart';

extension AsyncValueExt<T> on AsyncValue<T> {
  Future<T> get future {
    var completer = Completer<T>();

    maybeWhen(
      orElse: () {},
      data: (v) => completer.complete(v),
      error: (err, stack) => completer.completeError(err, stack),
    );

    return completer.future;
  }
}
