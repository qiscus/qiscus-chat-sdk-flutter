library qiscus_chat_sdk.usecase.app_config;

import 'package:fpdart/fpdart.dart';

import '../core.dart';

part 'api.dart';
part 'entity.dart';

RTE<AppConfig> getAppConfig = Reader((dio) {
  return tryCatch(() async {
    final req = GetConfigRequest();
    var appConfig = await req(dio);
    return appConfig;
  });
});

RTE<State<Storage, void>> appConfigUseCase =
    getAppConfig.map((task) => task.map((config) => config.hydrate()));
