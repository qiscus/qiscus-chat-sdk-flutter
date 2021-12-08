part of qiscus_chat_sdk;


class Injector {
  final c = GetIt.asNewInstance();

  void singleton<T extends Object>(T Function() inst, [String? name]) {
    c.registerLazySingleton<T>(inst, instanceName: name);
  }

  void factory_<T extends Object>(T Function() inst, [String? name]) {
    c.registerFactory(inst, instanceName: name);
  }

  T resolve<T extends Object>([String? name]) {
    return c.call<T>(instanceName: name);
  }

  void setup() {
    c.allowReassignment = true;
    _configure();
  }

  void configureCore() {
    // core
    singleton(() => Storage());
    factory_(() => Logger(resolve()));
  }

  void _configure() {
    singleton<Dio>(() => getDio(resolve(), resolve()));
    factory_<MqttClient>(() => getMqttClient(resolve()));
    singleton(() => AppConfigRepository(dio: resolve()));
    singleton(() => AppConfigUseCase(resolve(), resolve()));

    // realtime
    singleton(() => MqttServiceImpl(
          () => resolve(),
          resolve(),
          resolve(),
          resolve(),
        ));
    singleton(() => Interval(
          resolve(),
          resolve<MqttServiceImpl>(),
        ));
    singleton(() => SyncServiceImpl(
          storage: resolve(),
          interval: resolve(),
          logger: resolve(),
          dio: resolve(),
        ));
    singleton<IRealtimeService>(() => RealtimeServiceImpl(
          resolve<MqttServiceImpl>(),
          resolve<SyncServiceImpl>(),
        ));
    singleton(() => OnConnected(resolve()));
    singleton(() => OnDisconnected(resolve()));
    singleton(() => OnReconnecting(resolve()));

    // room
    factory_<IRoomRepository>(() => RoomRepositoryImpl(
          dio: resolve(),
          storage: resolve(),
        ));
    factory_(() => OnRoomMessagesCleared(resolve()));

    // user
    singleton<IUserRepository>(() => UserRepositoryImpl(resolve()));
    factory_(() => AuthenticateUserUseCase(
          resolve<IUserRepository>(),
          resolve(),
        ));
    factory_(() => AuthenticateUserWithTokenUseCase(
          resolve<IUserRepository>(),
          resolve(),
        ));
    factory_(() => BlockUserUseCase(resolve()));
    factory_(() => UnblockUserUseCase(resolve()));
    factory_(() => GetBlockedUserUseCase(resolve()));
    factory_(() => GetNonceUseCase(resolve()));
    factory_(() => GetUserDataUseCase(resolve()));
    factory_(() => GetUsersUseCase(resolve()));
    factory_(() => RegisterDeviceTokenUseCase(resolve()));
    factory_(() => UnregisterDeviceTokenUseCase(resolve()));
    factory_(() => UpdateUserUseCase(
          resolve(),
          resolve(),
        ));
    singleton(() => TypingUseCase(resolve()));
    singleton(() => PresenceUseCase(resolve()));

    // message
    singleton<MessageRepository>(() => MessageRepositoryImpl(resolve()));
    factory_(() => DeleteMessageUseCase(resolve()));
    factory_(() => GetMessageListUseCase(resolve()));
    factory_(() => SendMessageUseCase(resolve()));
    factory_(() => UpdateMessageStatusUseCase(resolve()));
    factory_(() => UpdateMessageUseCase(resolve()));
    singleton(() => OnMessageReceived(
          resolve(),
          resolve<UpdateMessageStatusUseCase>(),
        ));
    singleton(() => OnMessageDelivered(resolve()));
    singleton(() => OnMessageRead(resolve()));
    singleton(() => OnMessageDeleted(resolve()));
    singleton(() => OnMessageUpdated(resolve()));

    // custom event
    singleton(() => CustomEventUseCase(resolve()));
  }
}
