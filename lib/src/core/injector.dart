import 'package:kiwi/kiwi.dart' as kiwi;
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/features/core/core.dart';
import 'package:qiscus_chat_sdk/src/features/message/message.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/interval.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/realtime.dart';
import 'package:qiscus_chat_sdk/src/features/room/room.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';

@sealed
abstract class Injector {
  static final c = kiwi.Container.scoped();
  static final resolve = c.resolve;
  static final singleton = c.registerSingleton;
  static final factory = c.registerFactory;

  static T get<T>([String name]) => c.resolve<T>(name);

  static void setup() {
    _configure();
  }

  static void _configure() {
    // core
    singleton((c) => Storage());
    singleton((c) => Logger(c.resolve()));
    singleton((c) => getDio(c.resolve(), c.resolve()));
    singleton((c) => getMqttClient(c.resolve()));
    singleton((c) => CoreApi(c.resolve()));
    singleton<CoreRepository, CoreRepositoryImpl>(
        (c) => CoreRepositoryImpl(c.resolve()));
    singleton((c) => AppConfigUseCase(c.resolve(), c.resolve()));
    singleton((c) => Interval(c.resolve(), c.resolve()));

    // realtime
    singleton((c) => SyncApi(c.resolve()));
    singleton<RealtimeService, MqttServiceImpl>(
      (c) => MqttServiceImpl(
        () => c.resolve(),
        c.resolve(),
        c.resolve(),
      ),
      name: 'mqtt-service',
    );
    singleton<RealtimeService, SyncServiceImpl>(
      (c) => SyncServiceImpl(
        c.resolve(),
        c.resolve(),
        c.resolve(),
        c.resolve(),
      ),
      name: 'sync-service',
    );
    singleton<RealtimeService, RealtimeServiceImpl>(
      (c) => RealtimeServiceImpl(
        c.resolve('mqtt-service'),
        c.resolve('sync-service'),
      ),
    );

    // room
    singleton((c) => RoomApi(c.resolve()));
    singleton<RoomRepository, RoomRepositoryImpl>(
        (c) => RoomRepositoryImpl(c.resolve()));
    factory((c) => ClearRoomMessagesUseCase(c.resolve()));
    factory((c) => CreateGroupChatUseCase(c.resolve()));
    factory((c) => GetRoomUseCase(c.resolve()));
    factory((c) => GetRoomByUserIdUseCase(c.resolve()));
    factory((c) => GetRoomInfoUseCase(c.resolve()));
    factory((c) => GetRoomWithMessagesUseCase(c.resolve()));
    factory((c) => GetAllRoomsUseCase(c.resolve()));
    factory((c) => GetTotalUnreadCountUseCase(c.resolve()));
    factory((c) => AddParticipantUseCase(c.resolve()));
    factory((c) => GetParticipantsUseCase(c.resolve()));
    factory((c) => RemoveParticipantUseCase(c.resolve()));
    factory((c) => UpdateRoomUseCase(c.resolve()));

    // user
    singleton((c) => UserApi(c.resolve()));
    singleton<UserRepository, UserRepositoryImpl>(
        (c) => UserRepositoryImpl(c.resolve()));
    factory((c) => AuthenticateUserUseCase(c.resolve(), c.resolve()));
    factory((c) => AuthenticateUserWithTokenUseCase(c.resolve(), c.resolve()));
    factory((c) => BlockUserUseCase(c.resolve()));
    factory((c) => UnblockUserUseCase(c.resolve()));
    factory((c) => GetBlocedUserUseCase(c.resolve()));
    factory((c) => GetNonceUseCase(c.resolve()));
    factory((c) => GetUserDataUseCase(c.resolve()));
    factory((c) => GetUsersUseCase(c.resolve()));
    factory((c) => RegisterDeviceTokenUseCase(c.resolve()));
    factory((c) => UnregisterDeviceTokenUseCase(c.resolve()));
    factory((c) => UpdateUserUseCase(c.resolve(), c.resolve()));
    singleton((c) => TypingUseCase(c.resolve()));
    singleton((c) => PresenceUseCase(c.resolve()));

    // message
    singleton((c) => MessageApi(c.resolve()));
    singleton<MessageRepository, MessageRepositoryImpl>(
        (c) => MessageRepositoryImpl(c.resolve()));
    factory((c) => DeleteMessageUseCase(c.resolve()));
    factory((c) => GetMessageListUseCase(c.resolve()));
    factory((c) => SendMessageUseCase(c.resolve()));
    factory((c) => UpdateMessageStatusUseCase(c.resolve()));
    singleton((c) => OnMessageReceived(c.resolve()));
    singleton((c) => OnMessageDelivered(c.resolve()));
    singleton((c) => OnMessageRead(c.resolve()));
    singleton((c) => OnMessageDeleted(c.resolve()));
  }
}
