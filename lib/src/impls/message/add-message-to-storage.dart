
import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/domain/message/message-model.dart';

typedef StateMessages = State<Iterable<QMessage>, QMessage>;
final addMessageToStorage = StreamTransformer<QMessage, StateMessages>.fromBind(
  (stream) async* {
    await for (var message in stream) {
      yield State((Iterable<QMessage> messages) {
        return Tuple2(message, <QMessage>{...messages, message});
      });
    }
  },
);
