import 'package:fpdart/fpdart.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:qiscus_chat_sdk/src/core.dart';

Reader<Storage, bool> isAuthenticatedImpl = Reader((Storage s) {
  return s.currentUser != null;
});

final waitTillAuthenticatedImpl = Reader((Tuple2<MqttClient, Storage> s) {
  return Task(() async {
    return Stream.periodic(
      const Duration(milliseconds: 300),
      (_) => s.second.token != null,
    ).firstWhere((it) => it == true);
  });
});
