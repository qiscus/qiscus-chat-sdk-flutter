part of qiscus_chat_sdk;

class Injector {
  final c = GetIt.asNewInstance();

  T get<T>([String name]) {
    return c.get<T>(instanceName: name);
  }

  void setup() {
    // c.allowReassignment = true;
    _configure();
  }

  void _configure() {
    c.registerLazySingleton(() => Storage());
    c.registerLazySingleton(() => Logger(c.get()));
    c.registerLazySingleton(() => getDio(c.get(), c.get()));
    c.registerLazySingleton(() => getMqttClient(c.get()));
    c.registerLazySingleton(() => AppConfigRepository(dio: c.get()));
    c.registerLazySingleton(() => AppConfigUseCase(c.get(), c.get()));

    // realtime
    c.registerLazySingleton(() => MqttServiceImpl(
          () => c.get(),
          c.get(),
          c.get(),
          c.get(),
        ));
    c.registerLazySingleton(() => Interval(
          c.get(),
          c.get<MqttServiceImpl>(),
        ));
    c.registerLazySingleton(() => SyncServiceImpl(
          storage: c.get(),
          interval: c.get(),
          logger: c.get(),
          dio: c.get(),
        ));
    c.registerSingleton<IRealtimeService>(RealtimeServiceImpl(
      c.get<MqttServiceImpl>(),
      c.get<SyncServiceImpl>(),
    ));
    c.registerLazySingleton(() => OnConnected(c.get()));
    c.registerLazySingleton(() => OnDisconnected(c.get()));
    c.registerLazySingleton(() => OnReconnecting(c.get()));

    // room
    c.registerSingleton<IRoomRepository>(RoomRepositoryImpl(
      dio: c.get(),
      storage: c.get(),
    ));
    c.registerLazySingleton(() => OnRoomMessagesCleared(c.get()));

    // user
    c.registerSingleton<IUserRepository>(UserRepositoryImpl(c.get()));
    c.registerLazySingleton(() => AuthenticateUserUseCase(c.get(), c.get()));
    c.registerLazySingleton(
        () => AuthenticateUserWithTokenUseCase(c.get(), c.get()));
    c.registerLazySingleton(() => BlockUserUseCase(c.get()));
    c.registerLazySingleton(() => UnblockUserUseCase(c.get()));
    c.registerLazySingleton(() => GetBlockedUserUseCase(c.get()));
    c.registerLazySingleton(() => GetNonceUseCase(c.get()));
    c.registerLazySingleton(() => GetUserDataUseCase(c.get()));
    c.registerLazySingleton(() => GetUsersUseCase(c.get()));
    c.registerLazySingleton(() => RegisterDeviceTokenUseCase(c.get()));
    c.registerLazySingleton(() => UnregisterDeviceTokenUseCase(c.get()));
    c.registerLazySingleton(() => UpdateUserUseCase(c.get(), c.get()));
    c.registerLazySingleton(() => TypingUseCase(c.get()));

    // message
    c.registerSingleton<MessageRepository>(MessageRepositoryImpl(c.get()));
    c.registerFactory(() => DeleteMessageUseCase(c.get()));
    c.registerFactory(() => GetMessageListUseCase(c.get()));
    c.registerFactory(() => SendMessageUseCase(c.get()));
    c.registerFactory(() => UpdateMessageStatusUseCase(c.get()));
    c.registerFactory(() => UpdateMessageUseCase(c.get()));
    c.registerLazySingleton(() => PresenceUseCase(c.get()));
    c.registerLazySingleton(() => OnMessageReceived(c.get(), c.get()));
    c.registerLazySingleton(() => OnMessageDelivered(c.get()));
    c.registerLazySingleton(() => OnMessageRead(c.get()));
    c.registerLazySingleton(() => OnMessageDeleted(c.get()));
    c.registerLazySingleton(() => OnMessageUpdated(c.get()));

    // custom event
    c.registerLazySingleton(() => CustomEventUseCase(c.get()));
  }
}
