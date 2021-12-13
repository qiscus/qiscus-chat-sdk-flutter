import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/domain/message/message-model.dart';

typedef StateMessages = State<Iterable<QMessage>, QMessage>;
final addMessageToStorage =
StreamTransformer<QMessage, StateMessages>.fromHandlers(
  handleData: (message, sink) {
    sink.add(State((Iterable<QMessage> messages) {
      return Tuple2(message, <QMessage>{...messages, message});
    }));
  },
);
