import 'dart:async';
import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/domain/message/message-model.dart';
import 'package:qiscus_chat_sdk/src/impls/message/message-from-json-impl.dart';
import 'package:qiscus_chat_sdk/src/impls/mqtt-impls.dart';
import 'package:qiscus_chat_sdk/src/impls/sync.dart';

final StreamTransformer<QMqttMessage, State<Iterable<QMessage>, QMessage>>
mqttMessageUpdatedTransformerImpl
= StreamTransformer.fromBind((stream) async* {
  await for (var data in stream) {
    var json = jsonDecode(data.payload) as Map<String, dynamic>;
    var message = messageFromJson(json);

    yield State((messages) {
      return Tuple2(message, messages);
    });
  }
});

final StreamTransformer<QRealtimeEvent, State<Iterable<QMqttMessage>, QMqttMessage>>
syncMessageUpdatedTransformerImpl = StreamTransformer.fromBind((stream) async* {
  // Not Implemented for SyncEvent
});
