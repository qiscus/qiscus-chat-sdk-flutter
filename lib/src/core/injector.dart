import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../features/core/core.dart';
import '../features/message/message.dart';
import '../features/realtime/interval.dart';
import '../features/realtime/realtime.dart';
import '../features/room/room.dart';
import '../features/user/user.dart';
import 'core.dart';

@sealed
class Injector {
  final c = GetIt.asNewInstance();

  void singleton<T>(T Function() inst, [String name]) {
    c.registerLazySingleton<T>(inst, instanceName: name);
  }

  // ignore: non_constant_identifier_names
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
    singleton(() => Logger(resolve()));
    singleton<Dio>(() => getDio(resolve(), resolve()));
    singleton<MqttClient>(() => getMqttClient(resolve()));
    singleton(() => CoreRepository(dio: resolve()));
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
          resolve(),
        ));
    factory_(() => AuthenticateUserWithTokenUseCase(
          resolve<IUserRepository>(),
          resolve(),
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
          resolve(),
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
