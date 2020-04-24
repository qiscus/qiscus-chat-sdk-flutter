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
abstract class Injector {
  static final c = GetIt.asNewInstance();
  static final resolve = c.get;
  static final singleton = c.registerLazySingleton;
  static final lazySingleton = c.registerLazySingleton;
  static final factory = c.registerFactory;

  static T get<T>([String name]) => resolve<T>(instanceName: name);

  static void setup() {
    _configure();
  }

  static void _configure() {
    // core
    singleton(() => Storage());
    singleton(() => Logger(resolve<Storage>()));
    singleton<Dio>(() => getDio(resolve<Storage>(), resolve<Logger>()));
    singleton<MqttClient>(() => getMqttClient(resolve<Storage>()));
    singleton(() => CoreApi(resolve<Dio>()));
    singleton<CoreRepository>(() => CoreRepositoryImpl(resolve<CoreApi>()));
    singleton(
        () => AppConfigUseCase(resolve<CoreRepository>(), resolve<Storage>()));

    // realtime
    singleton(() => SyncApi(resolve<Dio>()));
    singleton(() => MqttServiceImpl(
          () => resolve<MqttClient>(),
          resolve<Storage>(),
          resolve<Logger>(),
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
    singleton<RealtimeService>(() => RealtimeServiceImpl(
          resolve<MqttServiceImpl>(),
          resolve<SyncServiceImpl>(),
        ));

    // room
    singleton(() => RoomApi(resolve<Dio>()));
    singleton<RoomRepository>(() => RoomRepositoryImpl(resolve<RoomApi>()));
    factory(() => ClearRoomMessagesUseCase(resolve<RoomRepository>()));
    factory(() => CreateGroupChatUseCase(resolve<RoomRepository>()));
    factory(() => GetRoomUseCase(resolve<RoomRepository>()));
    factory(() => GetRoomByUserIdUseCase(resolve<RoomRepository>()));
    factory(() => GetRoomInfoUseCase(resolve<RoomRepository>()));
    factory(() => GetRoomWithMessagesUseCase(resolve<RoomRepository>()));
    factory(() => GetAllRoomsUseCase(resolve<RoomRepository>()));
    factory(() => GetTotalUnreadCountUseCase(resolve<RoomRepository>()));
    factory(() => AddParticipantUseCase(resolve<RoomRepository>()));
    factory(() => GetParticipantsUseCase(resolve<RoomRepository>()));
    factory(() => RemoveParticipantUseCase(resolve<RoomRepository>()));
    factory(() => UpdateRoomUseCase(resolve<RoomRepository>()));

    // user
    singleton(() => UserApi(resolve<Dio>()));
    singleton<UserRepository>(() => UserRepositoryImpl(resolve<UserApi>()));
    factory(() => AuthenticateUserUseCase(
          resolve<UserRepository>(),
          resolve<Storage>(),
        ));
    factory(() => AuthenticateUserWithTokenUseCase(
          resolve<UserRepository>(),
          resolve<Storage>(),
        ));
    factory(() => BlockUserUseCase(resolve<UserRepository>()));
    factory(() => UnblockUserUseCase(resolve<UserRepository>()));
    factory(() => GetBlocedUserUseCase(resolve<UserRepository>()));
    factory(() => GetNonceUseCase(resolve<UserRepository>()));
    factory(() => GetUserDataUseCase(resolve<UserRepository>()));
    factory(() => GetUsersUseCase(resolve<UserRepository>()));
    factory(() => RegisterDeviceTokenUseCase(resolve<UserRepository>()));
    factory(() => UnregisterDeviceTokenUseCase(resolve<UserRepository>()));
    factory(() => UpdateUserUseCase(
          resolve<UserRepository>(),
          resolve<Storage>(),
        ));
    singleton(() => TypingUseCase(resolve<RealtimeService>()));
    singleton(() => PresenceUseCase(resolve<RealtimeService>()));

    // message
    singleton(() => MessageApi(resolve<Dio>()));
    singleton<MessageRepository>(
        () => MessageRepositoryImpl(resolve<MessageApi>()));
    factory(() => DeleteMessageUseCase(resolve<MessageRepository>()));
    factory(() => GetMessageListUseCase(resolve<MessageRepository>()));
    factory(() => SendMessageUseCase(resolve<MessageRepository>()));
    factory(() => UpdateMessageStatusUseCase(resolve<MessageRepository>()));
    singleton(() => OnMessageReceived(resolve<RealtimeService>()));
    singleton(() => OnMessageDelivered(resolve<RealtimeService>()));
    singleton(() => OnMessageRead(resolve<RealtimeService>()));
    singleton(() => OnMessageDeleted(resolve<RealtimeService>()));
  }
}
