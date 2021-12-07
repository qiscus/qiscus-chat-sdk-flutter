library qiscus_chat_sdk.usecase.custom_event;

import 'package:flutter/widgets.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../core.dart';
import '../message/message.dart';
import '../realtime/realtime.dart';

part 'entity.dart';

void publishCustomEvent(MqttClient mqtt) {

}

class CustomEventUseCase extends UseCase<IRealtimeService, void, CustomEvent>
    with SubscriptionMixin<IRealtimeService, RoomIdParams, CustomEvent> {
  CustomEventUseCase._(IRealtimeService s) : super(s);

  static CustomEventUseCase? _instance;

  factory CustomEventUseCase(IRealtimeService s) =>
      _instance ??= CustomEventUseCase._(s);

  @override
  Future<void> call(CustomEvent p) {
    return repository.publishCustomEvent(roomId: p.roomId, payload: p.payload);
  }

  @override
  Stream<CustomEvent> mapStream(RoomIdParams p) async* {
    yield* repository.subscribeCustomEvent(roomId: p.roomId);
  }

  @override
  Option<String> topic(RoomIdParams p) {
    return Option.of(TopicBuilder.customEvent(p.roomId));
  }
}
