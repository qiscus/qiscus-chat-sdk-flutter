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

    // room
    singleton(() => RoomApi(resolve<Dio>()));
    singleton<RoomRepository>(() => RoomRepositoryImpl(resolve<RoomApi>()));
    factory_(() => ClearRoomMessagesUseCase(resolve<RoomRepository>()));
    factory_(() => CreateGroupChatUseCase(resolve<RoomRepository>()));
    factory_(() => GetRoomUseCase(resolve<RoomRepository>()));
    factory_(() => GetRoomByUserIdUseCase(resolve<RoomRepository>()));
    factory_(() => GetRoomInfoUseCase(resolve<RoomRepository>()));
    factory_(() => GetRoomWithMessagesUseCase(resolve<RoomRepository>()));
    factory_(() => GetAllRoomsUseCase(resolve<RoomRepository>()));
    factory_(() => GetTotalUnreadCountUseCase(resolve<RoomRepository>()));
    factory_(() => AddParticipantUseCase(resolve<RoomRepository>()));
    factory_(() => GetParticipantsUseCase(resolve<RoomRepository>()));
    factory_(() => RemoveParticipantUseCase(resolve<RoomRepository>()));
    factory_(() => UpdateRoomUseCase(resolve<RoomRepository>()));

    // user
    singleton(() => UserApi(resolve<Dio>()));
    singleton<IUserRepository>(() => UserRepositoryImpl(resolve<UserApi>()));
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
    singleton(() => MessageApi(resolve<Dio>()));
    singleton<MessageRepository>(
        () => MessageRepositoryImpl(resolve<MessageApi>()));
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
