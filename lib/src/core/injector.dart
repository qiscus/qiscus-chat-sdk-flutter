import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/features/core/core.dart';
import 'package:qiscus_chat_sdk/src/features/message/message.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/interval.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/realtime.dart';
import 'package:qiscus_chat_sdk/src/features/room/room.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';

@sealed
class Injector {
  final c = GetIt.asNewInstance();

  void singleton<T>(T Function() inst, [String name]) {
    c.registerLazySingleton<T>(inst, instanceName: name);
  }

  void factory_<T>(T Function() inst, [String name]) {
    c.registerFactory(inst, instanceName: name);
  }

  T resolve<T>([String name]) {
    return c.get<T>(instanceName: name);
  }

  T get<T>([String name]) {
    return resolve<T>(name);
  }

  void setup() {
    _configure();
  }

  void _configure() {
    // core
    singleton(() => Storage());
    singleton(() => Logger(resolve<Storage>()));
    singleton<Dio>(() => getDio(resolve<Storage>(), resolve<Logger>()));
    singleton<MqttClient>(() => getMqttClient(resolve<Storage>()));
    singleton(() => CoreApi(resolve<Dio>()));
    singleton<CoreRepository>(() => CoreRepositoryImpl(resolve<CoreApi>()));
    singleton(
      () => AppConfigUseCase(resolve<CoreRepository>(), resolve<Storage>()),
    );

    // realtime
    singleton(() => SyncApi(resolve<Dio>()));
    singleton(() => MqttServiceImpl(
          () => resolve<MqttClient>(),
          resolve<Storage>(),
          resolve<Logger>(),
          resolve<Dio>(),
        ));
    singleton(() => Interval(
          resolve<Storage>(),
          resolve<MqttServiceImpl>(),
        ));
    singleton(() => SyncServiceImpl(
          resolve<Storage>(),
          resolve<SyncApi>(),
          resolve<Interval>(),
          resolve<Logger>(),
        ));
    singleton<IRealtimeService>(() => RealtimeServiceImpl(
          resolve<MqttServiceImpl>(),
          resolve<SyncServiceImpl>(),
        ));
    singleton(() => OnConnected(resolve()));
    singleton(() => OnDisconnected(resolve()));
    singleton(() => OnReconnecting(resolve()));

    // room
    singleton<IRoomRepository>(() => RoomRepositoryImpl(
          dio: resolve(),
        ));
    factory_(() => ClearRoomMessagesUseCase(resolve<IRoomRepository>()));
    factory_(() => CreateGroupChatUseCase(resolve<IRoomRepository>()));
    factory_(() => GetRoomUseCase(resolve<IRoomRepository>()));
    factory_(() => GetRoomByUserIdUseCase(resolve<IRoomRepository>()));
    factory_(() => GetRoomInfoUseCase(resolve<IRoomRepository>()));
    factory_(() => GetRoomWithMessagesUseCase(resolve<IRoomRepository>()));
    factory_(() => GetAllRoomsUseCase(resolve<IRoomRepository>()));
    factory_(() => GetTotalUnreadCountUseCase(resolve<IRoomRepository>()));
    factory_(() => AddParticipantUseCase(resolve<IRoomRepository>()));
    factory_(() => GetParticipantsUseCase(resolve<IRoomRepository>()));
    factory_(() => RemoveParticipantUseCase(resolve<IRoomRepository>()));
    factory_(() => UpdateRoomUseCase(resolve<IRoomRepository>()));
    factory_(() => OnRoomMessagesCleared(resolve()));

    // user
    singleton<IUserRepository>(() => UserRepositoryImpl(resolve()));
    factory_(() => AuthenticateUserUseCase(
          resolve<IUserRepository>(),
          resolve<Storage>(),
        ));
    factory_(() => AuthenticateUserWithTokenUseCase(
          resolve<IUserRepository>(),
          resolve<Storage>(),
        ));
    factory_(() => BlockUserUseCase(resolve<IUserRepository>()));
    factory_(() => UnblockUserUseCase(resolve<IUserRepository>()));
    factory_(() => GetBlockedUserUseCase(resolve<IUserRepository>()));
    factory_(() => GetNonceUseCase(resolve<IUserRepository>()));
    factory_(() => GetUserDataUseCase(resolve<IUserRepository>()));
    factory_(() => GetUsersUseCase(resolve<IUserRepository>()));
    factory_(() => RegisterDeviceTokenUseCase(resolve<IUserRepository>()));
    factory_(() => UnregisterDeviceTokenUseCase(resolve<IUserRepository>()));
    factory_(() => UpdateUserUseCase(
          resolve<IUserRepository>(),
          resolve<Storage>(),
        ));
    singleton(() => TypingUseCase(resolve<IRealtimeService>()));
    singleton(() => PresenceUseCase(resolve<IRealtimeService>()));

    // message
    singleton<MessageRepository>(() => MessageRepositoryImpl(resolve()));
    factory_(() => DeleteMessageUseCase(resolve<MessageRepository>()));
    factory_(() => GetMessageListUseCase(resolve<MessageRepository>()));
    factory_(() => SendMessageUseCase(resolve<MessageRepository>()));
    factory_(() => UpdateMessageStatusUseCase(resolve<MessageRepository>()));
    singleton(() => OnMessageReceived(
          resolve<IRealtimeService>(),
          resolve<UpdateMessageStatusUseCase>(),
        ));
    singleton(() => OnMessageDelivered(resolve<IRealtimeService>()));
    singleton(() => OnMessageRead(resolve<IRealtimeService>()));
    singleton(() => OnMessageDeleted(resolve<IRealtimeService>()));
  }
}
