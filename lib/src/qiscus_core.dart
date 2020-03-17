library qiscus_chat_sdk;

import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';
import 'package:qiscus_chat_sdk/src/core/storage.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/message/entity.dart';
import 'package:qiscus_chat_sdk/src/features/message/repository.dart';
import 'package:qiscus_chat_sdk/src/features/message/repository_impl.dart';
import 'package:qiscus_chat_sdk/src/features/message/usecase/get_message_list.dart';
import 'package:qiscus_chat_sdk/src/features/message/usecase/on_deleted.dart';
import 'package:qiscus_chat_sdk/src/features/message/usecase/on_message_received.dart';
import 'package:qiscus_chat_sdk/src/features/message/usecase/send_message.dart';
import 'package:qiscus_chat_sdk/src/features/message/usecase/update_status.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/interval.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/mqtt_service_impl.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/service.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/service_impl.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/sync_service_impl.dart';
import 'package:qiscus_chat_sdk/src/features/room/entity.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository_impl.dart';
import 'package:qiscus_chat_sdk/src/features/room/usecase/get_room_by_user_id.dart';
import 'package:qiscus_chat_sdk/src/features/room/usecase/get_room_with_messages.dart';
import 'package:qiscus_chat_sdk/src/features/sync/api.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/account.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/participant.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/user.dart';
import 'package:qiscus_chat_sdk/src/features/user/repository.dart';
import 'package:qiscus_chat_sdk/src/features/user/repository_impl.dart';
import 'package:qiscus_chat_sdk/src/features/user/usecases/authenticate.dart';
import 'package:qiscus_chat_sdk/src/features/user/usecases/authenticate_with_token.dart';
import 'package:qiscus_chat_sdk/src/features/user/usecases/block_user.dart';
import 'package:qiscus_chat_sdk/src/features/user/usecases/get_blocked_user.dart';
import 'package:qiscus_chat_sdk/src/features/user/usecases/get_nonce.dart';
import 'package:qiscus_chat_sdk/src/features/user/usecases/get_user_data.dart';
import 'package:qiscus_chat_sdk/src/features/user/usecases/get_users.dart';
import 'package:qiscus_chat_sdk/src/features/user/usecases/on_user_typing.dart';
import 'package:qiscus_chat_sdk/src/features/user/usecases/register_device_token.dart';
import 'package:qiscus_chat_sdk/src/features/user/usecases/update_user.dart';
import 'package:qiscus_chat_sdk/src/features/user/user_api.dart';

import 'features/message/api.dart';
import 'features/room/api.dart';
import 'features/user/usecases/unblock_user.dart';

typedef Subscription = void Function();

typedef UserPresenceHandler = void Function(String, bool, DateTime);
typedef UserTypingHandler = void Function(String, int, bool);

class QiscusSDK {
  static final instance = QiscusSDK();
  static final _storage = Storage();

  static final _logger = Logger(printer: LogfmtPrinter());

  static Dio get _dio {
    final interceptor = InterceptorsWrapper(
      onRequest: (request) {
        request.baseUrl = '${_storage?.baseUrl}/api/v2/mobile/';
        request.headers['qiscus-sdk-app-id'] = 'sdksample';
        request.headers['qiscus-sdk-version'] = 'dart-alpha1.0';
        if (_storage?.token != null) {
          request.headers['qiscus-sdk-token'] = _storage.token;
          request.headers['qiscus-sdk-user-id'] = _storage.userId;
        }
        return request;
      },
    );
    return Dio(BaseOptions())
      ..interceptors.addAll([
        interceptor,
//        PrettyDioLogger(responseBody: false, request: false),
      ]);
  }

  static final _userApi = UserApi(_dio);
  static final _syncApi = SyncApi(_dio);
  static final _roomApi = RoomApi(_dio);
  static final _messageApi = MessageApi(_dio);

  static String get _clientId =>
      'dart-sdk-${DateTime.now().millisecondsSinceEpoch}';

  static MqttClient get _mqttClient {
    final _connectionMessage = MqttConnectMessage() //
            // .keepAliveFor(10)
            .withClientIdentifier(_clientId)
            .withWillTopic('u/${_storage.currentUser.id}/s')
            .withWillMessage('0')
            .withWillRetain()
        // .startClean()
        //
        ;

    var brokerUrl = 'wss://mqtt.qiscus.com/mqtt';
    var client = MqttServerClient(brokerUrl, 'sdk-dart')
          ..logging(on: false)
          ..useWebSocket = true
          ..port = 1886
          ..connectionMessage = _connectionMessage
          ..websocketProtocols = ['mqtt']
        //
        ;
    return client;
  }

  static final RealtimeService _mqttService = MqttServiceImpl(
    () => _mqttClient,
    _storage,
  );

  static final _interval = Interval(_storage, _mqttService);
  static final RealtimeService _syncService = SyncServiceImpl(
    _storage,
    _syncApi,
    _interval,
  );
  static final RealtimeService _realtimeService = RealtimeServiceImpl(
    _mqttService as MqttServiceImpl,
    _syncService as SyncServiceImpl,
  );
  static final UserRepository _userRepo = UserRepositoryImpl(_userApi);
  static final RoomRepository _roomRepo = RoomRepositoryImpl(_roomApi);
  static final MessageRepository _messageRepo =
      MessageRepositoryImpl(_messageApi);

  factory QiscusSDK() => QiscusSDK._internal();

  factory QiscusSDK.withAppId(
    String appId, {
    @required void Function(Exception) callback,
  }) {
    return QiscusSDK()..setup(appId, callback: callback);
  }

  factory QiscusSDK.withCustomServer(
    String appId, {
    String baseUrl = Storage.defaultBaseUrl,
    String brokerUrl = Storage.defaultBrokerUrl,
    String brokerLbUrl = Storage.defaultBrokerLbUrl,
    int syncInterval = Storage.defaultSyncInterval,
    int syncIntervalWhenConnected = Storage.defaultSyncIntervalWhenConnected,
    @required Function1<Exception, void> callback,
  }) {
    return QiscusSDK()
      ..setupWithCustomServer(
        appId,
        baseUrl: baseUrl,
        brokerUrl: brokerUrl,
        brokerLbUrl: brokerLbUrl,
        syncInterval: syncInterval,
        syncIntervalWhenConnected: syncIntervalWhenConnected,
        callback: callback,
      );
  }

  QiscusSDK._internal();

  String get appId => _storage?.appId;

  QAccount get currentUser => _storage?.currentUser?.toModel();

  bool get isLogin => _storage?.currentUser != null;

  Storage get s => _storage;

  String get token => _storage?.token;

  final _messageReceived$ = StreamController<Message>.broadcast();
  final _messageRead$ = StreamController<Message>.broadcast();
  final _messageDelivered$ = StreamController<Message>.broadcast();
  final _userTyping$ = StreamController<TypingResponse>.broadcast();

  Task<Either<Exception, void>> get _authenticated =>
      Task(() => _isLogin).attempt().leftMapToException('Not logged in');

  Future<bool> get _isLogin =>
      Stream<void>.periodic(const Duration(milliseconds: 300))
          .map((_) => currentUser != null)
          .distinct((p, n) => p == n)
          .firstWhere((it) => it == true)
          .then(
            (isLogin) => !isLogin
                ? Future.error('Not authenticated')
                : Future.value(null),
          );

  void addParticipants({
    @required int roomId,
    @required List<String> userIds,
    @required void Function(List<QParticipant>, Exception) callback,
  }) {}

  void blockUser({
    @required String userId,
    @required void Function(QUser, Exception) callback,
  }) {
    _authenticated
        .andThen(BlockUser(_userRepo).call(BlockUserParams(userId)))
        .rightMap((it) => it.toModel())
        .toCallback(callback)
        .run();
  }

  void chatUser({
    @required String userId,
    Map<String, dynamic> extras,
    @required Function2<QChatRoom, Exception, void> callback,
  }) {
    _authenticated
        .andThen(GetRoomByUserId(_roomRepo).call(UserIdParams(userId)))
        .rightMap((u) => u.toModel())
        .toCallback(callback)
        .run();
  }

  void clearMessagesByChatRoomId({
    @required List<String> roomUniqueIds,
    @required void Function(Error) callback,
  }) {}

  void clearUser({
    @required void Function(Exception) callback,
  }) {}

  void createChannel({
    @required String uniqueId,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
    @required void Function(QChatRoom, Exception) callback,
  }) {}

  void createGroupChat({
    @required String name,
    @required List<String> userIds,
    String avatarUrl,
    Map<String, dynamic> extras,
    @required void Function(QChatRoom, Exception) callback,
  }) {}

  void deleteMessages({
    @required List<String> messageUniqueIds,
    @required void Function(List<QMessage>, Exception) callback,
  }) {}

  void enableDebugMode({bool enable = false}) {}

  void getAllChatRooms({
    bool showParticipant,
    bool showRemoved,
    bool showEmpty,
    @required void Function(List<QChatRoom>, Exception) callback,
  }) {}

  void getBlockedUsers({
    int page,
    int limit,
    @required void Function(List<QUser>, Exception) callback,
  }) {
    _authenticated
        .andThen(GetBlockedUser(_userRepo).call(
          GetBlockedUserParams(
            page: page,
            limit: limit,
          ),
        ))
        .rightMap((it) => it.map((u) => u.toModel()).toList())
        .toCallback(callback)
        .run();
  }

  void getChannel({
    @required String uniqueId,
    @required void Function(QChatRoom, Exception) callback,
  }) {}

  void getChatRooms({
    List<int> roomIds, // ignore: always_require_non_null_named_parameters
    List<String> uniqueIds, // ignore: always_require_non_null_named_parameters
    int page,
    bool showRemoved,
    bool showParticipants,
    @required void Function(List<QChatRoom>, Exception) callback,
  }) {
    // Throw error if both roomIds and uniqueIds are null
    assert(roomIds == null && uniqueIds == null);
    assert(roomIds != null && uniqueIds != null);
  }

  void getChatRoomWithMessages({
    @required int roomId,
    @required void Function(QChatRoom, Exception) callback,
  }) {
    _authenticated
        .andThen(GetRoomWithMessages(_roomRepo).call(RoomIdParams(roomId)))
        .rightMap((it) => it.toModel())
        .toCallback(callback)
        .run();
  }

  void getJWTNonce({
    void Function(String, Exception) callback,
  }) {
    GetNonce(_userRepo).call(NoParams()).toCallback(callback).run();
  }

  void getNextMessagesById({
    @required int roomId,
    @required int messageId,
    int limit,
    @required void Function(List<QMessage>, Exception) callback,
  }) {
    _authenticated
        .andThen(GetMessageList(_messageRepo).call(GetMessageListParams(
          roomId,
          messageId,
          after: true,
          limit: limit,
        )))
        .rightMap((it) => it.map((it) => it.toModel()).toList())
        .toCallback(callback)
        .run();
  }

  void getParticipants({
    @required String roomUniqueId,
    int page,
    int limit,
    String sorting,
    @required void Function(List<QParticipant>, Exception) callback,
  }) {}

  void getPreviousMessagesById({
    @required int roomId,
    int limit,
    int messageId,
    @required void Function(List<QMessage>, Exception) callback,
  }) {}

  String getThumbnailURL(String url) => '';

  void getTotalUnreadCount({
    @required void Function(int, Exception) callback,
  }) {}

  void getUserData({
    void Function(QAccount, Exception) callback,
  }) {
    _authenticated
        .andThen(GetUserData(_userRepo).call(NoParams()))
        .rightMap((user) => user.toModel())
        .toCallback(callback)
        .run();
  }

  void getUsers({
    @deprecated String searchUsername,
    int page,
    int limit,
    @required void Function(List<QUser>, Exception) callback,
  }) {
    _authenticated
        .andThen(GetUsers(_userRepo).call(GetUserParams(
          query: searchUsername,
          page: page,
          limit: limit,
        )))
        .rightMap((it) => it.map((u) => u.toModel()).toList())
        .toCallback(callback)
        .run();
  }

  void hasSetupUser({
    @required void Function(bool) callback,
  }) {
    callback(currentUser != null);
  }

  void intercept({
    @required String interceptor,
    @required Future<QMessage> Function(QMessage) callback,
  }) {}

  void markAsDelivered({
    @required int roomId,
    @required int messageId,
    @required void Function(Exception) callback,
  }) {
    _authenticated
        .andThen(UpdateStatus(_messageRepo).call(UpdateStatusParams(
          roomId,
          messageId,
          QMessageStatus.delivered,
        )))
        .toCallback((_, e) => callback(e))
        .run();
  }

  void markAsRead({
    @required int roomId,
    @required int messageId,
    @required void Function(Exception) callback,
  }) {
    _authenticated
        .andThen(UpdateStatus(_messageRepo).call(UpdateStatusParams(
          roomId,
          messageId,
          QMessageStatus.read,
        )))
        .toCallback((_, e) => callback(e))
        .run();
  }

  Subscription onChatRoomCleared(void Function(int) callback) {
    return () => null;
  }

  Subscription onConnected(void Function() handler) => () {};

  Subscription onDisconnected(void Function() handler) => () {};

  Subscription onMessageDeleted(Function1<QMessage, void> callback) {
    var subs = _authenticated
        .andThen(OnMessageDeleted(_realtimeService)(NoParams()))
        .rightMap((s) {
      return s.listen((m) => callback(m.toModel()));
    }).run();
    return () {
      return subs.then((e) => e.fold(
            (_) => none,
            (s) => some(s.cancel()),
          ));
    };
  }

  Subscription onMessageDelivered(void Function(QMessage) callback) {
    final subs = _messageDelivered$.stream
        .asyncMap((it) => it.toModel())
        .listen((data) => callback(data));
    return () => subs.cancel();
  }

  Subscription onMessageRead(void Function(QMessage) callback) {
    final subs = _messageRead$.stream
        .asyncMap((it) => it.toModel())
        .listen((m) => callback(m));
    return () => subs.cancel();
  }

  Subscription onMessageReceived(void Function(QMessage) callback) {
    var subs = _realtimeService
        .subscribeMessageReceived()
        .asyncMap((m) => m.toModel())
        .listen((m) => callback(m));
    return () => subs.cancel();
  }

  Subscription onReconnecting(void Function() handler) => () {};

  Subscription onUserOnlinePresence(UserPresenceHandler handler) => () {};

  Subscription onUserTyping(Function3<String, int, bool, void> handler) {
    var subs = _authenticated.bind((_) {
      return Task.delay(
        () => catching(
          () => _userTyping$.stream.listen((response) {
            handler(response.userId, response.roomId, response.isTyping);
          }),
        ),
      );
    }).run();
    return () => subs.then((either) => either.fold(
          (l) => none(),
          (r) => r.cancel(),
        ));
  }

  void publishCustomEvent({
    @required int roomId,
    @required Map<String, dynamic> payload,
    @required void Function(Error) callback,
  }) {}

  void publishOnlinePresence({
    @required bool isOnline,
    @required void Function(Error) callback,
  }) {}

  void publishTyping({
    @required int roomId,
    bool isTyping,
  }) {}

  void registerDeviceToken({
    @required String token,
    bool isDevelopment,
    void Function(bool, Exception) callback,
  }) {
    _authenticated
        .andThen(RegisterDeviceToken(_userRepo).call(DeviceTokenParams(
          token,
          isDevelopment,
        )))
        .toCallback(callback)
        .run();
  }

  void removeDeviceToken({
    @required String token,
    bool isDevelopment,
    void Function(bool, Exception) callback,
  }) {
    _authenticated
        .andThen(UnregisterDeviceToken(_userRepo).call(DeviceTokenParams(
          token,
          isDevelopment,
        )))
        .toCallback(callback)
        .run();
  }

  void removeParticipants({
    @required int roomId,
    @required List<String> userIds,
    @required void Function(List<QParticipant>, Exception) callback,
  }) {}

  void sendFileMessage({
    @required int roomId,
    @required void Function(Exception, double, QMessage) callback,
    @required String message,
    @required File file,
  }) {}

  void sendMessage({
    @required QMessage message,
    @required void Function(QMessage, Exception) callback,
  }) {
    _authenticated //
        .andThen(SendMessage(_messageRepo).call(MessageParams(message)))
        .rightMap((it) => it.toModel())
        .toCallback(callback)
        .run();
  }

  void setCustomHeader(Map<String, String> headers) {
    _storage.customHeaders = headers;
  }

  void setSyncInterval(double interval) {}

  void setup(String appId, {@required Function1<Exception, void> callback}) {
    setupWithCustomServer(appId, callback: callback);
  }

  void setupWithCustomServer(
    String appId, {
    String baseUrl = Storage.defaultBaseUrl,
    String brokerUrl = Storage.defaultBrokerUrl,
    String brokerLbUrl = Storage.defaultBrokerLbUrl,
    int syncInterval = Storage.defaultSyncInterval,
    int syncIntervalWhenConnected = Storage.defaultSyncIntervalWhenConnected,
    @required Function1<Exception, void> callback,
  }) {
    _storage.appId = appId;
    _storage.baseUrl = baseUrl;
    _storage.brokerUrl = brokerUrl;
    _storage.brokerLbUrl = brokerLbUrl;
    _storage.syncInterval = syncInterval;
    _storage.syncIntervalWhenConnected = syncIntervalWhenConnected;
    // TODO: call callback from success init config
    callback(null);
  }

  void setUser({
    @required String userId,
    @required String userKey,
    String username,
    String avatarUrl,
    Map<String, dynamic> extras,
    @required void Function(QAccount, Exception) callback,
  }) {
    var subscribes = (token) => _realtimeService //
        .subscribe(TopicBuilder.messageNew(token))
        .andThen(_realtimeService.subscribe(TopicBuilder.notification(token)));
    Authenticate(_userRepo, _storage)
        .call(AuthenticateParams(
          userId: userId,
          userKey: userKey,
          name: username,
          avatarUrl: avatarUrl,
          extras: extras,
        ))
        .bind((either) => either.fold(
              (e) =>
                  Task.delay(() => left<Exception, Tuple2<String, Account>>(e)),
              (tuple) => subscribes(tuple.value1).andThen(Task.delay(
                  () => right<Exception, Tuple2<String, Account>>(tuple))),
            ))
        .rightMap((tuple) => tuple.value2.toModel())
        .toCallback(callback)
        .run();
  }

  void setUserWithIdentityToken({
    String token,
    @required void Function(QAccount, Exception) callback,
  }) {
    AuthenticateWithToken(_userRepo, _storage)
        .call(AuthenticateWithTokenParams(token))
        .rightMap((user) => user.toModel())
        .toCallback(callback)
        .run();
  }

  void subscribeChatRoom(QChatRoom room) {
    final roomId = room.id.toString();
    final params = RoomIdParams(room.id);

    final sRead = _realtimeService
        .subscribe(TopicBuilder.messageRead(roomId))
        .andThen(OnMessageRead(_realtimeService).call(params))
        .bind((either) => Task(() async =>
            either.map((stream) => _messageRead$.addStream(stream))));
    final sDelivered = _realtimeService
        .subscribe(TopicBuilder.messageDelivered(roomId))
        .andThen(OnMessageDelivered(_realtimeService).call(params))
        .bind((either) => Task(() async => either.map(
              (stream) => _messageDelivered$.addStream(stream),
            )));
    final sTyping = _realtimeService
        .subscribe(TopicBuilder.typing(roomId, '+'))
        .andThen(OnUserTyping(_realtimeService).call(params))
        .bind((either) => Task(() async =>
            either.map((stream) => _userTyping$.addStream(stream))));

    _authenticated //
        .andThen(sRead)
        .andThen(sDelivered)
        .andThen(sTyping)
        .run();
  }

  void subscribeCustomEvent({
    @required int roomId,
    @required void Function(Map<String, dynamic>) callback,
  }) {}

  void subscribeUserOnlinePresence(String userId) {}

  void synchronize({String lastMessageId}) {}

  void synchronizeEvent({String lastEventId}) {}

  void unblockUser({
    @required String userId,
    @required void Function(QUser, Exception) callback,
  }) {
    _authenticated
        .andThen(UnblockUser(_userRepo).call(UnblockUserParams(userId)))
        .rightMap((u) => u.toModel())
        .toCallback(callback)
        .run();
  }

  void unsubscribeCustomEvent({
    @required int roomId,
  }) {}

  void unsubscribeUserOnlinePresence(String userId) {}

  void updateChatRoom({
    int roomId,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
    @required void Function(QChatRoom, Exception) callback,
  }) {}

  void updateUser({
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
    @required void Function(QAccount, Exception) callback,
  }) {
    _authenticated
        .andThen(UpdateUser(_userRepo, _storage).call(UpdateUserParams(
          name: name,
          avatarUrl: avatarUrl,
          extras: extras,
        )))
        .rightMap((u) => u.toModel())
        .toCallback(callback)
        .run();
  }

  void upload({
    @required File file,
    @required void Function(Exception, double, String) callback,
  }) {}
}

extension _TaskX<L1, R1> on Task<Either<L1, R1>> {
  Task<Either<void, void>> toCallback(void Function(R1, L1) callback) {
    return leftMap((err) {
      callback(null, err);
    }).rightMap((val) {
      callback(val, null);
    });
  }
}
