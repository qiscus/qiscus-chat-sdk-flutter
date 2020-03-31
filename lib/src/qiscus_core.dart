library qiscus_chat_sdk;

import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:qiscus_chat_sdk/src/features/custom_event/usecase/realtime.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/usecase/realtime.dart';
import 'package:qiscus_chat_sdk/src/features/room/usecase/participant.dart';

import 'core/core.dart';
import 'features/message/api.dart';
import 'features/message/message.dart';
import 'features/realtime/realtime.dart';
import 'features/room/api.dart';
import 'features/room/room.dart';
import 'features/user/usecases/unblock_user.dart';
import 'features/user/user.dart';

typedef Subscription = void Function();

typedef UserPresenceHandler = void Function(String, bool, DateTime);
typedef UserTypingHandler = void Function(String, int, bool);

class QiscusSDK {
  static final instance = QiscusSDK();
  static final _storage = Storage();

  static final _logger = Logger();

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
//        PrettyDioLogger(
//          requestBody: true,
//          requestHeader: true,
//        ),
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
  }) {
    _authenticated
        .andThen(AddParticipantUseCase(_roomRepo)(
            ParticipantParams(roomId, userIds)))
        .rightMap((r) => r.map((m) => m.toModel()).toList())
        .toCallback(callback)
        .run();
  }

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
    @required void Function(QChatRoom, List<QMessage>, Exception) callback,
  }) {
    _authenticated
        .andThen(GetRoomWithMessages(_roomRepo).call(RoomIdParams(roomId)))
        .leftMap((err) => callback(null, null, err))
        .rightMap((it) => callback(
              it.value1.toModel(),
              it.value2.map((m) => m.toModel()).toList(),
              null,
            ))
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
        .andThen(GetMessageList(_messageRepo)(
          GetMessageListParams(roomId, messageId, after: true, limit: limit),
        ))
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
  }) {
    _authenticated
        .andThen(GetParticipantsUseCase(_roomRepo)(
        RoomUniqueIdsParams(roomUniqueId)))
        .rightMap((r) => r.map((p) => p.toModel()).toList())
        .toCallback(callback)
        .run();
  }

  void getPreviousMessagesById({
    @required int roomId,
    int limit,
    int messageId,
    @required Function2<List<QMessage>, Exception, void> callback,
  }) {
    _authenticated
        .andThen(GetMessageList(_messageRepo)(
          GetMessageListParams(roomId, messageId, after: false, limit: limit),
        ))
        .rightMap((it) => it.map((m) => m.toModel()).toList())
        .toCallback(callback)
        .run();
  }

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

  Subscription onConnected(void Function() handler) {
    var ret = _authenticated
        .andThen(OnConnected(_realtimeService).subscribe(NoParams()))
        .bind((stream) => Task.delay(() => stream.listen((_) => handler())))
        .run();
    return () => ret.then((s) => s.cancel());
  }

  Subscription onDisconnected(void Function() handler) {
    var ret = _authenticated
        .andThen(OnDisconnected(_realtimeService).subscribe(noParams))
        .bind((s) => Task.delay(() => s.listen((_) => handler())))
        .run();
    return () => ret.then((s) => s.cancel());
  }

  Subscription onMessageDeleted(Function1<QMessage, void> callback) {
    var subs = _authenticated
        .andThen(OnMessageDeleted(_realtimeService)
            .listen((m) => callback(m.toModel())))
        .run();
    return () => subs.then((s) => s.cancel());
  }

  Subscription onMessageDelivered(void Function(QMessage) callback) {
    final subs = _authenticated
        .andThen(OnMessageDelivered(_realtimeService)
            .listen((m) => callback(m.toModel())))
        .run();
    return () => subs.then((s) => s.cancel());
  }

  Subscription onMessageRead(void Function(QMessage) callback) {
    final subs = _authenticated
        .andThen(OnMessageRead(_realtimeService)
            .listen((m) => callback(m.toModel())))
        .run();
    return () => subs.then((s) => s.cancel());
  }

  Subscription onMessageReceived(void Function(QMessage) callback) {
    var subs = _authenticated
        .andThen(OnMessageReceived(_realtimeService)
            .listen((m) => callback(m.toModel())))
        .run();
    return () => subs.then((s) => s.cancel());
  }

  Subscription onReconnecting(void Function() handler) {
    var ret = _authenticated
        .andThen(OnReconnecting(_realtimeService).subscribe(noParams))
        .bind((s) => Task.delay(() => s.listen((_) => handler())))
        .run();
    return () => ret.then((s) => s.cancel());
  }

  Subscription onUserOnlinePresence(
    void Function(String, bool, DateTime) handler,
  ) {
    final subs = _authenticated //
        .andThen(PresenceUseCase(_realtimeService).listen((data) {
          handler(data.userId, data.isOnline, data.lastSeen);
        }))
        .run();
    return () => subs.then((s) => s.cancel());
  }

  Subscription onUserTyping(void Function(String, int, bool) handler) {
    var subs = _authenticated
        .andThen(TypingUseCase(_realtimeService).listen((data) {
          handler(data.userId, data.roomId, data.isTyping);
        }))
        .run();
    return () => subs.then((s) => s.cancel());
  }

  void publishCustomEvent({
    @required int roomId,
    @required Map<String, dynamic> payload,
    @required void Function(Exception) callback,
  }) {
    _authenticated
        .andThen(
      CustomEventUseCase(_realtimeService)(CustomEvent(roomId, payload)),
    )
        .map((either) => either.fold((e) => callback(e), (_) {}))
        .run();
  }

  void publishOnlinePresence({
    @required bool isOnline,
    @required void Function(Exception) callback,
  }) {
    _authenticated
        .andThen(PresenceUseCase(_realtimeService).call(Presence(
          userId: _storage.userId,
          isOnline: isOnline,
          lastSeen: DateTime.now(),
        )))
        .leftMap((error) => callback(error))
        .run();
  }

  void publishTyping({
    @required int roomId,
    bool isTyping,
  }) {
    _authenticated
        .andThen(TypingUseCase(_realtimeService).call(Typing(
          userId: _storage.userId,
          roomId: roomId,
          isTyping: isTyping,
        )))
        .run();
  }

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
    @required void Function(List<String>, Exception) callback,
  }) {
    _authenticated
        .andThen(RemoveParticipantUseCase(_roomRepo)(
        ParticipantParams(roomId, userIds)))
        .toCallback(callback)
        .run();
  }

  void sendFileMessage({
    @required QMessage message,
    @required File file,
    @required void Function(Exception, double, QMessage) callback,
  }) {
    upload(
      file: file,
      callback: (error, progress, url) async {
        if (error != null) return callback(error, null, null);
        if (error == null && progress != null) {
          return callback(null, progress, null);
        }
        message.payload ??= {};
        message.payload['url'] = url;
        message.payload['size'] = await message.payload['size'];
        message.text = '[file] $url [/file]';
        sendMessage(
            message: message,
            callback: (message, error) {
              callback(error, null, message);
            });
      },
    );
  }

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
    var subscribes = (token) => OnMessageReceived(_realtimeService)
        .subscribe(TokenParams(token))
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

  void unsubscribeChatRoom(QChatRoom room) {
    final params = RoomIdParams(room.id);

    final read = OnMessageRead(_realtimeService).unsubscribe(params);
    final delivered = OnMessageDelivered(_realtimeService).unsubscribe(params);
    final typing = OnMessageDelivered(_realtimeService).unsubscribe(params);

    _authenticated.andThen(read).andThen(delivered).andThen(typing).run();
  }

  void subscribeChatRoom(QChatRoom room) {
    final params = RoomIdParams(room.id);

    final read = OnMessageRead(_realtimeService).subscribe(params);
    final delivered = OnMessageDelivered(_realtimeService).subscribe(params);
    final typing = TypingUseCase(_realtimeService).subscribe(Typing(
      roomId: room.id,
      userId: '+',
    ));
    _authenticated.andThen(read).andThen(delivered).andThen(typing).run();
  }

  void subscribeCustomEvent({
    @required int roomId,
    @required void Function(Map<String, dynamic>) callback,
  }) {
    _authenticated
        .andThen(CustomEventUseCase(_realtimeService)
        .subscribe(RoomIdParams(roomId)))
        .bind((stream) =>
        Task.delay(() => stream.listen((data) => callback(data.payload))))
        .run();
  }

  void subscribeUserOnlinePresence(String userId) {
    _authenticated
        .andThen(PresenceUseCase(_realtimeService)
            .subscribe(Presence(userId: userId)))
        .run();
  }

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

  void unsubscribeCustomEvent({@required int roomId}) {
    _authenticated
        .andThen(CustomEventUseCase(_realtimeService)
        .unsubscribe(RoomIdParams(roomId)))
        .run();
  }

  void unsubscribeUserOnlinePresence(String userId) {
    _authenticated
        .andThen(PresenceUseCase(_realtimeService)
        .unsubscribe(Presence(userId: userId)))
        .run();
  }

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
  }) async {
    var filename = file.path.split('/').last;
    var formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: filename),
    });
    await _dio.post(
      _storage.uploadUrl,
      data: formData,
      onSendProgress: (count, total) {
        var percentage = (count / total) * 100;
        callback(null, percentage, null);
      },
    ).then((resp) {
      print('got resp: $resp');
      var json = resp.data;
      print(json);
      print(json.runtimeType);
      var url = json['results']['file']['url'] as String;
      callback(null, null, url);
    }).catchError((error) {
      callback(Exception(error.toString()), null, null);
    });
  }
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
