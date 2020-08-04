library qiscus_chat_sdk;

import 'dart:async';
import 'dart:io' if (dart.library.html) 'dart:html';
import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import 'core/core.dart';
import 'core/errors.dart';
import 'core/injector.dart';
import 'core/utils.dart';
import 'features/channel/channel.dart';
import 'features/core/core.dart';
import 'features/custom_event/usecase/realtime.dart';
import 'features/message/message.dart';
import 'features/realtime/realtime.dart';
import 'features/room/room.dart';
import 'features/user/user.dart';

typedef Subscription = void Function();
typedef UserPresenceHandler = void Function(String, bool, DateTime);
typedef UserTypingHandler = void Function(String, int, bool);

class QiscusSDK {
  static final instance = QiscusSDK();

  final injector = Injector();

  factory QiscusSDK() => QiscusSDK._internal();

  factory QiscusSDK.withAppId(
    String appId, {
    @required void Function(QError) callback,
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
    @required Function1<QError, void> callback,
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

  static Future<QiscusSDK> withAppId$(String appId) async {
    return futurify2<QiscusSDK>((cb) {
      var qiscus = QiscusSDK();

      qiscus.setup(
        appId,
        callback: (err) {
          cb(qiscus, err);
        },
      );
    });
  }

  static Future<QiscusSDK> withCustomServer$(
    String appId, {
    String baseUrl = Storage.defaultBaseUrl,
    String brokerUrl = Storage.defaultBrokerUrl,
    String brokerLbUrl = Storage.defaultBrokerLbUrl,
    int syncInterval = Storage.defaultSyncInterval,
    int syncIntervalWhenConnected = Storage.defaultSyncIntervalWhenConnected,
  }) async {
    return futurify2<QiscusSDK>((cb) {
      var qiscus = QiscusSDK();

      qiscus.setupWithCustomServer(
        appId,
        callback: (err) {
          cb(qiscus, err);
        },
        baseUrl: baseUrl,
        brokerUrl: brokerUrl,
        brokerLbUrl: brokerLbUrl,
        syncInterval: syncInterval,
        syncIntervalWhenConnected: syncIntervalWhenConnected,
      );
    });
  }

  QiscusSDK._internal() {
    injector.setup();
  }

  T _get<T>([String name]) {
    return injector.get<T>(name);
  }

  String get appId => _get<Storage>()?.appId;

  QAccount get currentUser => _get<Storage>()?.currentUser?.toModel();

  bool get isLogin => _get<Storage>()?.currentUser != null;

  String get token => _get<Storage>()?.token;

  Task<Either<QError, void>> get _authenticated {
    final _isLogin = Stream<void>.periodic(const Duration(milliseconds: 300))
        .map((_) => isLogin)
        .distinct((p, n) => p == n)
        .firstWhere((it) => it == true);
    return Task(() => _isLogin).attempt().leftMapToQError('Not logged in');
  }

  void addHttpInterceptors(RequestOptions Function(RequestOptions) onRequest) {
    _get<Dio>().interceptors.add(InterceptorsWrapper(
          onRequest: onRequest,
        ));
  }

  void addParticipants({
    @required int roomId,
    @required List<String> userIds,
    @required void Function(List<QParticipant>, QError) callback,
  }) {
    final params = ParticipantParams(roomId, userIds);
    final useCase = _get<AddParticipantUseCase>();
    final addParticipant = _authenticated.andThen(useCase(params));
    addParticipant
        .rightMap((r) => r.map((m) => m.toModel()).toList())
        .toCallback_(callback);
  }

  void blockUser({
    @required String userId,
    @required void Function(QUser, QError) callback,
  }) {
    final blockUser = _get<BlockUserUseCase>();
    _authenticated
        .andThen(blockUser(BlockUserParams(userId)))
        .rightMap((it) => it.toModel())
        .toCallback_(callback);
  }

  void chatUser({
    @required String userId,
    Map<String, dynamic> extras,
    @required Function2<QChatRoom, QError, void> callback,
  }) {
    _authenticated
        .andThen(_get<GetRoomByUserIdUseCase>()(UserIdParams(
          userId: userId,
          extras: extras,
        )))
        .rightMap((u) => u.toModel())
        .toCallback_(callback);
  }

  void clearMessagesByChatRoomId({
    @required List<String> roomUniqueIds,
    @required void Function(QError) callback,
  }) {
    final clearRoom = _get<ClearRoomMessagesUseCase>();
    _authenticated
        .andThen(clearRoom(ClearRoomMessagesParams(roomUniqueIds)))
        .toCallback1(callback)
        .run();
  }

  void clearUser({
    @required void Function(QError) callback,
  }) {
    _authenticated
        .andThen(Task.delay(() => _get<Storage>().clear()))
        .andThen(Task.delay(() => _get<MqttServiceImpl>().end()))
        .andThen(Task.delay(() => _get<SyncServiceImpl>().end()))
        .toCallback_((_, error) => callback(error));
  }

  void createChannel({
    @required String uniqueId,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
    @required void Function(QChatRoom, QError) callback,
  }) {
    final useCase = _get<GetOrCreateChannelUseCase>();
    _authenticated
        .andThen(useCase(GetOrCreateChannelParams(
          uniqueId,
          name: name,
          avatarUrl: avatarUrl,
          options: extras,
        )))
        .rightMap((room) => room.toModel())
        .toCallback_(callback);
  }

  void createGroupChat({
    @required String name,
    @required List<String> userIds,
    String avatarUrl,
    Map<String, dynamic> extras,
    @required void Function(QChatRoom, QError) callback,
  }) {
    final useCase = _get<CreateGroupChatUseCase>();
    _authenticated
        .andThen(useCase(CreateGroupChatParams(
          name: name,
          userIds: userIds,
          avatarUrl: avatarUrl,
          extras: extras,
        )))
        .rightMap((r) => r.toModel())
        .toCallback_(callback);
  }

  void deleteMessages({
    @required List<String> messageUniqueIds,
    @required void Function(List<QMessage>, QError) callback,
  }) {
    final deleteMessages = _get<DeleteMessageUseCase>();
    _authenticated
        .andThen(deleteMessages(DeleteMessageParams(messageUniqueIds)))
        .rightMap((it) => it.map((i) => i.toModel()).toList())
        .toCallback_(callback);
  }

  void enableDebugMode({
    @required bool enable,
    QLogLevel level = QLogLevel.verbose,
  }) {
    _get<Storage>()
      ..debugEnabled = enable
      ..logLevel = level;
  }

  void getAllChatRooms({
    bool showParticipant,
    bool showRemoved,
    bool showEmpty,
    int limit,
    int page,
    @required void Function(List<QChatRoom>, QError) callback,
  }) {
    final params = GetAllRoomsParams(
      withParticipants: showParticipant,
      withRemovedRoom: showRemoved,
      withEmptyRoom: showEmpty,
      limit: limit,
      page: page,
    );
    final useCase = _get<GetAllRoomsUseCase>();
    _authenticated
        .andThen(useCase(params))
        .rightMap((r) => r.map((c) => c.toModel()).toList())
        .toCallback_(callback);
  }

  void getBlockedUsers({
    int page,
    int limit,
    @required void Function(List<QUser>, QError) callback,
  }) {
    final params = GetBlockedUserParams(page: page, limit: limit);
    final useCase = _get<GetBlockedUserUseCase>();
    _authenticated
        .andThen(useCase(params))
        .rightMap((it) => it.map((u) => u.toModel()).toList())
        .toCallback_(callback);
  }

  void getChannel({
    @required String uniqueId,
    @required void Function(QChatRoom, QError) callback,
  }) {
    final params = GetOrCreateChannelParams(uniqueId);
    final useCase = _get<GetOrCreateChannelUseCase>();
    _authenticated
        .andThen(useCase(params))
        .rightMap((r) => r.toModel())
        .toCallback_(callback);
  }

  void getChatRooms({
    List<int> roomIds,
    List<String> uniqueIds,
    int page,
    bool showRemoved,
    bool showParticipants,
    @required void Function(List<QChatRoom>, QError) callback,
  }) {
    const errorMessage = 'Please specify either `roomIds` or `uniqueIds`';
    // Throw error if both roomIds and uniqueIds are null
    if (roomIds == null && uniqueIds == null) {
      return callback(null, QError(errorMessage));
    }
    if (roomIds != null && uniqueIds != null) {
      return callback(null, QError(errorMessage));
    }

    final params = GetRoomInfoParams(
      roomIds: roomIds,
      uniqueIds: uniqueIds,
      withRemoved: showRemoved,
      withParticipants: showParticipants,
      page: page,
    );
    final useCase = _get<GetRoomInfoUseCase>();
    _authenticated
        .andThen(useCase(params))
        .rightMap((r) => r.map((it) => it.toModel()).toList())
        .toCallback_(callback);
  }

  void getChatRoomWithMessages({
    @required int roomId,
    @required void Function(QChatRoom, List<QMessage>, QError) callback,
  }) {
    final useCase = _get<GetRoomWithMessagesUseCase>();
    _authenticated
        .andThen(useCase(RoomIdParams(roomId)))
        .rightMap((it) => QChatRoomWithMessages(
              it.value1.toModel(),
              it.value2.map((i) => i.toModel()).toList(),
            ))
        .toCallback_((data, error) {
      callback(data.room, data.messages, error);
    });
  }

  void getJWTNonce({void Function(String, QError) callback}) {
    _get<GetNonceUseCase>()(NoParams()).toCallback_(callback);
  }

  void getNextMessagesById({
    @required int roomId,
    @required int messageId,
    int limit,
    @required void Function(List<QMessage>, QError) callback,
  }) {
    final useCase = _get<GetMessageListUseCase>();
    final params =
        GetMessageListParams(roomId, messageId, after: true, limit: limit);
    _authenticated
        .andThen(useCase(params))
        .rightMap((it) => it.map((it) => it.toModel()).toList())
        .toCallback_(callback);
  }

  void getParticipants({
    @required String roomUniqueId,
    int page,
    int limit,
    String sorting,
    @required void Function(List<QParticipant>, QError) callback,
  }) {
    _authenticated
        .andThen(
            _get<GetParticipantsUseCase>()(RoomUniqueIdsParams(roomUniqueId)))
        .rightMap((r) => r.map((p) => p.toModel()).toList())
        .toCallback_(callback);
  }

  void getPreviousMessagesById({
    @required int roomId,
    int limit,
    int messageId,
    @required Function2<List<QMessage>, QError, void> callback,
  }) {
    _authenticated
        .andThen(_get<GetMessageListUseCase>()(
          GetMessageListParams(roomId, messageId, after: false, limit: limit),
        ))
        .rightMap((it) => it.map((m) => m.toModel()).toList())
        .toCallback_(callback);
  }

  String getThumbnailURL(String url) => url;

  void getTotalUnreadCount({
    @required void Function(int, QError) callback,
  }) {
    _authenticated
        .andThen(_get<GetTotalUnreadCountUseCase>()(noParams))
        .toCallback_(callback);
  }

  void getUserData({
    @required void Function(QAccount, QError) callback,
  }) {
    var useCase = _get<GetUserDataUseCase>();
    _authenticated
        .andThen(useCase(noParams))
        .rightMap((u) => u.toModel())
        .toCallback_(callback);
  }

  void getUsers({
    @deprecated String searchUsername,
    int page,
    int limit,
    @required void Function(List<QUser>, QError) callback,
  }) {
    final params = GetUserParams(
      query: searchUsername,
      page: page,
      limit: limit,
    );
    final getUsers = _get<GetUsersUseCase>();
    return _authenticated
        .andThen(getUsers(params))
        .rightMap((u) => u.map((u) => u.toModel()).toList())
        .toCallback_(callback);
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
    @required void Function(QError) callback,
  }) {
    _authenticated
        .andThen(_get<UpdateMessageStatusUseCase>()(UpdateStatusParams(
          roomId,
          messageId,
          QMessageStatus.delivered,
        )))
        .rightMap((_) => null)
        .toCallback_((_, e) => callback(e));
  }

  void markAsRead({
    @required int roomId,
    @required int messageId,
    @required void Function(QError) callback,
  }) {
    _authenticated
        .andThen(_get<UpdateMessageStatusUseCase>()(UpdateStatusParams(
          roomId,
          messageId,
          QMessageStatus.read,
        )))
        .toCallback_((_, e) => callback(e));
  }

  Subscription onChatRoomCleared(void Function(int) handler) {
    var ret = _authenticated
        .andThen(_get<OnRoomMessagesCleared>().subscribe(noParams))
        .bind((s) => Task.delay(() => s.listen((it) => handler(it))))
        .run();
    return () => ret.then<void>((s) => s.cancel());
  }

  Subscription onConnected(void Function() handler) {
    var ret = _authenticated
        .andThen(_get<OnConnected>().subscribe(noParams))
        .bind((stream) => Task.delay(() => stream.listen((_) => handler())))
        .run();
    return () => ret.then<void>((s) => s.cancel());
  }

  Subscription onDisconnected(void Function() handler) {
    var ret = _authenticated
        .andThen(_get<OnDisconnected>().subscribe(noParams))
        .bind((s) => Task.delay(() => s.listen((_) => handler())))
        .run();
    return () => ret.then<void>((s) => s.cancel());
  }

  Subscription onMessageDeleted(Function1<QMessage, void> callback) {
    var subs = _authenticated
        .andThen(_get<OnMessageDeleted>().listen((m) => callback(m.toModel())))
        .run();
    return () => subs.then<void>((s) => s.cancel());
  }

  Subscription onMessageDelivered(void Function(QMessage) callback) {
    final subs = _authenticated
        .andThen(
            _get<OnMessageDelivered>().listen((m) => callback(m.toModel())))
        .run();
    return () => subs.then<void>((s) => s.cancel());
  }

  Subscription onMessageRead(void Function(QMessage) callback) {
    final subs = _authenticated
        .andThen(_get<OnMessageRead>().listen((m) => callback(m.toModel())))
        .run();
    return () => subs.then<void>((s) => s.cancel());
  }

  Subscription onMessageReceived(void Function(QMessage) callback) {
    var token = _get<Storage>().token;
    var listenable = _get<OnMessageReceived>()
        .subscribe(TokenParams(token))
        .bind<StreamSubscription<Message>>((stream) =>
            Task.delay(() => stream.listen((m) => callback(m.toModel()))));

    var subs = _authenticated.andThen(listenable).run();
    return () => subs.then<void>((s) => s.cancel());
  }

  Subscription onReconnecting(void Function() handler) {
    var ret = _authenticated
        .andThen(_get<OnReconnecting>().subscribe(noParams))
        .bind((s) => Task.delay(() => s.listen((_) => handler())))
        .run();
    return () => ret.then<void>((s) => s.cancel());
  }

  Subscription onUserOnlinePresence(
    void Function(String, bool, DateTime) handler,
  ) {
    final subs = _authenticated //
        .andThen(_get<PresenceUseCase>().listen((data) {
          handler(data.userId, data.isOnline, data.lastSeen);
        }))
        .run();
    return () => subs.then<void>((s) => s.cancel());
  }

  Subscription onUserTyping(void Function(String, int, bool) handler) {
    var subs = _authenticated
        .andThen(_get<TypingUseCase>().listen((data) {
          handler(data.userId, data.roomId, data.isTyping);
        }))
        .run();
    return () => subs.then<void>((s) => s.cancel());
  }

  void publishCustomEvent({
    @required int roomId,
    @required Map<String, dynamic> payload,
    @required void Function(QError) callback,
  }) {
    _authenticated
        .andThen(
          _get<CustomEventUseCase>()(CustomEvent(roomId, payload)),
        )
        .map((either) => either.fold((e) => callback(e), (_) {}))
        .run();
  }

  void publishOnlinePresence({
    @required bool isOnline,
    @required void Function(QError) callback,
  }) {
    _authenticated
        .andThen(_get<PresenceUseCase>()(Presence(
          userId: _get<Storage>().userId,
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
        .andThen(_get<TypingUseCase>()(Typing(
          userId: _get<Storage>().userId,
          roomId: roomId,
          isTyping: isTyping,
        )))
        .run();
  }

  Future<bool> registerDeviceToken$({
    @required String token,
    bool isDevelopment,
  }) async {
    var useCase = _get<RegisterDeviceTokenUseCase>();
    var params = DeviceTokenParams(token, isDevelopment);
    return _authenticated.andThen(useCase(params)).toFuture();
  }

  void registerDeviceToken({
    @required String token,
    bool isDevelopment,
    void Function(bool, QError) callback,
  }) {
    registerDeviceToken$(token: token, isDevelopment: isDevelopment)
        .toCallback2(callback);
  }

  Future<bool> removeDeviceToken$({
    @required String token,
    bool isDevelopment,
  }) async {
    var useCase = _get<UnregisterDeviceTokenUseCase>();
    var params = DeviceTokenParams(token, isDevelopment);
    return _authenticated.andThen(useCase(params)).toFuture();
  }

  void removeDeviceToken({
    @required String token,
    bool isDevelopment,
    void Function(bool, QError) callback,
  }) {
    return removeDeviceToken$(token: token, isDevelopment: isDevelopment)
        .toCallback2(callback);
  }

  void removeParticipants({
    @required int roomId,
    @required List<String> userIds,
    @required void Function(List<String>, QError) callback,
  }) {
    var removeParticipants = _get<RemoveParticipantUseCase>();
    var params = ParticipantParams(roomId, userIds);
    _authenticated.andThen(removeParticipants(params)).toCallback_(callback);
  }

  void sendFileMessage({
    @required QMessage message,
    @required File file,
    @required void Function(QError, double, QMessage) callback,
  }) {
    upload(
      file: file,
      callback: (error, progress, url) async {
        if (error != null) return callback(error, null, null);
        if (error == null && progress != null) {
          return callback(null, progress, null);
        }
        message.payload ??= <String, dynamic>{};
        message.payload['url'] = url;
        message.payload['size'] ??= await file.length();
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
    @required void Function(QMessage, QError) callback,
  }) {
    _authenticated
        .andThen(Task.delay(() {
          message.sender = _get<Storage>().currentUser?.toModel()?.asUser();
          return message;
        }))
        .bind((message) => _get<SendMessageUseCase>()(MessageParams(message)))
        .rightMap((it) => it.toModel())
        .toCallback_(callback);
  }

  void setCustomHeader(Map<String, String> headers) {
    _get<Storage>().customHeaders = headers;
  }

  void setSyncInterval(double interval) {
    _get<Storage>().syncInterval = interval.ceil();
  }

  void setup(
    String appId, {
    @required Function1<QError, void> callback,
  }) {
    setupWithCustomServer(appId, callback: callback);
  }

  Future<void> setupWithCustomServer$(
    String appId, {
    String baseUrl = Storage.defaultBaseUrl,
    String brokerUrl = Storage.defaultBrokerUrl,
    String brokerLbUrl = Storage.defaultBrokerLbUrl,
    int syncInterval = Storage.defaultSyncInterval,
    int syncIntervalWhenConnected = Storage.defaultSyncIntervalWhenConnected,
  }) async {}

  void setupWithCustomServer(
    String appId, {
    String baseUrl = Storage.defaultBaseUrl,
    String brokerUrl = Storage.defaultBrokerUrl,
    String brokerLbUrl = Storage.defaultBrokerLbUrl,
    int syncInterval = Storage.defaultSyncInterval,
    int syncIntervalWhenConnected = Storage.defaultSyncIntervalWhenConnected,
    @required Function1<QError, void> callback,
  }) {
    final storage = _get<Storage>();
    storage
      ..appId = appId
      ..baseUrl = baseUrl
      ..brokerUrl = brokerUrl
      ..brokerLbUrl = brokerLbUrl
      ..syncInterval = syncInterval
      ..syncIntervalWhenConnected = syncIntervalWhenConnected;

    _get<AppConfigUseCase>() //
        .call(noParams)
        .toCallback_((_, e) => callback(e));
  }

  Task<Either<QError, void>> _subscribes(String token) {
    final onMessageReceived = _get<OnMessageReceived>();
    final realtimeService = _get<IRealtimeService>();

    return onMessageReceived
        .subscribe(TokenParams(token))
        .andThen(realtimeService.subscribe(TopicBuilder.notification(token)));
  }

  void setUser({
    @required String userId,
    @required String userKey,
    String username,
    String avatarUrl,
    Map<String, dynamic> extras,
    @required void Function(QAccount, QError) callback,
  }) {
    final authenticate = _get<AuthenticateUserUseCase>();
    final params = AuthenticateParams(
      userId: userId,
      userKey: userKey,
      name: username,
      avatarUrl: avatarUrl,
      extras: extras,
    );
    authenticate(params)
        .bind((either) {
          return either.fold(
            (e) {
              return Task.delay(() {
                return left<QError, Tuple2<String, Account>>(e);
              });
            },
            (tuple) {
              return _subscribes(tuple.value1).andThen(Task.delay(
                () {
                  return right<QError, Tuple2<String, Account>>(tuple);
                },
              ));
            },
          );
        })
        .rightMap((it) => it.value2.toModel())
        .toCallback_(callback);
  }

  void setUserWithIdentityToken({
    @required String token,
    @required void Function(QAccount, QError) callback,
  }) {
    _get<AuthenticateUserWithTokenUseCase>()
        .call(AuthenticateWithTokenParams(token))
        .rightMap((user) => user.toModel())
        .toCallback_(callback);
  }

  void unsubscribeChatRoom(QChatRoom room) {
    final params = RoomIdParams(room.id);

    final read = _get<OnMessageRead>().unsubscribe(params);
    final delivered = _get<OnMessageDelivered>().unsubscribe(params);
    final typing = _get<TypingUseCase>().unsubscribe(Typing(
      roomId: room.id,
      userId: '+',
    ));

    _authenticated.andThen(read).andThen(delivered).andThen(typing).run();
  }

  void subscribeChatRoom(QChatRoom room) {
    final params = RoomIdParams(room.id);

    final read = _get<OnMessageRead>().subscribe(params);
    final delivered = _get<OnMessageDelivered>().subscribe(params);
    final typing = _get<TypingUseCase>().subscribe(Typing(
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
        .andThen(_get<CustomEventUseCase>().subscribe(RoomIdParams(roomId)))
        .bind((stream) =>
            Task.delay(() => stream.listen((data) => callback(data.payload))))
        .run();
  }

  void subscribeUserOnlinePresence(String userId) {
    _authenticated
        .andThen(_get<PresenceUseCase>().subscribe(Presence(userId: userId)))
        .run();
  }

  void synchronize({String lastMessageId}) {
    _authenticated
        .andThen(_get<IRealtimeService>().synchronize(int.parse(lastMessageId)))
        .run()
        .catchError((dynamic _) {});
  }

  void synchronizeEvent({String lastEventId}) {
    _authenticated
        .andThen(_get<IRealtimeService>().synchronizeEvent(lastEventId))
        .run()
        .catchError((dynamic _) {});
  }

  void unblockUser({
    @required String userId,
    @required void Function(QUser, QError) callback,
  }) {
    _authenticated
        .andThen(_get<UnblockUserUseCase>().call(UnblockUserParams(userId)))
        .rightMap((u) => u.toModel())
        .toCallback_(callback);
  }

  void unsubscribeCustomEvent({@required int roomId}) {
    _authenticated
        .andThen(_get<CustomEventUseCase>().unsubscribe(RoomIdParams(roomId)))
        .run();
  }

  void unsubscribeUserOnlinePresence(String userId) {
    _authenticated
        .andThen(_get<PresenceUseCase>().unsubscribe(Presence(userId: userId)))
        .run();
  }

  void updateChatRoom({
    int roomId,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
    @required void Function(QChatRoom, QError) callback,
  }) {
    _authenticated
        .andThen(_get<UpdateRoomUseCase>()(UpdateRoomParams(
          roomId: roomId,
          name: name,
          avatarUrl: avatarUrl,
          extras: extras,
        )))
        .rightMap((r) => r.toModel())
        .toCallback_(callback);
  }

  void updateUser({
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
    @required void Function(QAccount, QError) callback,
  }) {
    var useCase = _get<UpdateUserUseCase>();
    var params = UpdateUserParams(
      name: name,
      avatarUrl: avatarUrl,
      extras: extras,
    );
    _authenticated
        .andThen(useCase(params))
        .rightMap((u) => u.toModel())
        .toCallback_(callback);
  }

  void upload({
    @required File file,
    @required void Function(QError, double, String) callback,
  }) async {
    final uploadUrl = _get<Storage>().uploadUrl;
    final dio = _get<Dio>();
    var filename = file.path.split('/').last;
    var formData = FormData.fromMap(<String, dynamic>{
      'file': await MultipartFile.fromFile(file.path, filename: filename),
    });
    await dio.post<Map<String, dynamic>>(
      uploadUrl,
      data: formData,
      onSendProgress: (count, total) {
        var percentage = (count / total) * 100;
        callback(null, percentage, null);
      },
    ).then((resp) {
      var json = resp.data;
      var url = json['results']['file']['url'] as String;
      callback(null, null, url);
    }).catchError((dynamic error) {
      callback(QError(error.toString()), null, null);
    });
  }

  String _generateUniqueId() =>
      'flutter-${DateTime.now().millisecondsSinceEpoch}';

  QMessage generateMessage({
    @required int chatRoomId,
    @required String text,
    Map<String, dynamic> extras,
  }) {
    var id = Random.secure().nextInt(10000);
    return QMessage(
      // Provided by user
      chatRoomId: chatRoomId,
      text: text,
      extras: extras,
      timestamp: DateTime.now(),
      uniqueId: _generateUniqueId(),
      //
      id: id,
      payload: null,
      previousMessageId: 0,
      sender: currentUser.asUser(),
      status: QMessageStatus.sending,
      type: QMessageType.text,
    );
  }

  QMessage generateCustomMessage({
    @required int chatRoomId,
    @required String text,
    @required String type,
    Map<String, dynamic> extras,
    @required Map<String, dynamic> payload,
  }) {
    var id = Random.secure().nextInt(10000);
    return QMessage(
      // Provided by user
      chatRoomId: chatRoomId,
      text: text,
      timestamp: DateTime.now(),
      uniqueId: _generateUniqueId(),
      extras: extras,
      payload: <String, dynamic>{
        'type': type,
        'content': payload,
      },
      //
      id: id,
      previousMessageId: 0,
      sender: currentUser.asUser(),
      status: QMessageStatus.sending,
      type: QMessageType.custom,
    );
  }

  QMessage generateFileAttachmentMessage({
    @required int chatRoomId,
    @required String caption,
    @required String url,
    String filename,
    String text = 'File attachment',
    int size,
    Map<String, dynamic> extras,
  }) {
    var id = Random.secure().nextInt(10000);
    return QMessage(
      // Provided by user
      chatRoomId: chatRoomId,
      text: text,
      timestamp: DateTime.now(),
      uniqueId: _generateUniqueId(),
      extras: extras,
      payload: <String, dynamic>{
        'url': url,
        'file_name': filename,
        'size': size,
        'caption': caption,
      },
      //
      id: id,
      previousMessageId: 0,
      sender: currentUser.asUser(),
      status: QMessageStatus.sending,
      type: QMessageType.attachment,
    );
  }
}

class QChatRoomWithMessages {
  const QChatRoomWithMessages(this.room, this.messages);

  final QChatRoom room;
  final List<QMessage> messages;
}

class QUserPresence {
  String userId;
  bool isOnline;
  DateTime lastOnline;
}

class QUserTyping {
  String userId;
  int roomId;
  bool isTyping;
}
