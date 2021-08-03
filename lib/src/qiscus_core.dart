library qiscus_chat_sdk;

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'core.dart';
import 'app_config/app_config.dart';
import 'custom_event/custom_event.dart';
import 'message/message.dart';
import 'realtime/realtime.dart';
import 'room/room.dart';
import 'user/user.dart';
import 'type_utils.dart';

part 'injector.dart';

class QiscusSDK {
  static final instance = QiscusSDK();
  final _injector = Injector();

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
    @required void Function(Exception) callback,
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
    _injector.configureCore();
    _injector.setup();
  }

  T __<T>([String name]) => _injector.get<T>(name);
  String get appId => __<Storage>()?.appId;
  QAccount get currentUser => __<Storage>()?.currentUser?.toModel();
  bool get isLogin => __<Storage>()?.currentUser != null;
  String get token => __<Storage>()?.token;
  Future<bool> get _authenticated => __<Storage>().authenticated$;
  IRoomRepository get _room$$ => __<IRoomRepository>();
  Storage get storage => __<Storage>();

  void addHttpInterceptors(RequestOptions Function(RequestOptions) onRequest) {
    __<Dio>().interceptors.add(InterceptorsWrapper(
          onRequest: onRequest,
        ));
  }

  void addParticipants({
    @required int roomId,
    @required List<String> userIds,
    @required void Function(List<QParticipant>, Exception) callback,
  }) {
    Future.sync(() async {
      var res = await _room$$.addParticipant(roomId, userIds);
      return res.map((m) => m.toModel()).toList();
    }).toCallback2(callback);
  }

  void blockUser({
    @required String userId,
    @required void Function(QUser, Exception) callback,
  }) {
    final blockUser = __<BlockUserUseCase>();
    Future.sync(() async {
      await _authenticated;
      var res = await blockUser(BlockUserParams(userId));
      return res.toModel();
    }).toCallback2(callback);
  }

  void chatUser({
    @required String userId,
    Map<String, dynamic> extras,
    @required void Function(QChatRoom, Exception) callback,
  }) {
    Future.sync(() async {
      await _authenticated;
      var res = await _room$$.getRoomWithUserId(userId: userId, extras: extras);
      return res.toModel();
    }).toCallback2(callback);
  }

  void clearMessagesByChatRoomId({
    @required List<String> roomUniqueIds,
    @required void Function(Exception) callback,
  }) {
    Future.sync(() async {
      await _authenticated;
      return _room$$.clearMessages(uniqueIds: roomUniqueIds);
    }).toCallback1(callback);
  }

  void clearUser({@required void Function(Exception) callback}) {
    var clearSubscription = () => Future.wait([
          __<OnMessageDelivered>().clear(),
          __<OnMessageRead>().clear(),
          __<OnMessageReceived>().clear(),
          __<OnMessageDeleted>().clear(),
          __<OnMessageUpdated>().clear(),
          __<TypingUseCase>().clear(),
          __<PresenceUseCase>().clear(),
          __<CustomEventUseCase>().clear(),
          __<OnDisconnected>().clear(),
          __<OnConnected>().clear(),
          __<OnReconnecting>().clear(),
        ]);

    Future.sync(() async {
      await _authenticated;
      await clearSubscription();
      __<Storage>().clear();
      await __<IRealtimeService>().end();
    }).toCallback1(callback);
  }

  void createChannel({
    @required String uniqueId,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
    @required void Function(QChatRoom, Exception) callback,
  }) {
    Future.sync(() async {
      await _authenticated;
      var res = await _room$$.getOrCreateChannel(
        uniqueId: uniqueId,
        name: name,
        avatarUrl: avatarUrl,
        options: extras,
      );

      return res.toModel();
    }).toCallback2(callback);
  }

  void createGroupChat({
    @required String name,
    @required List<String> userIds,
    String avatarUrl,
    Map<String, dynamic> extras,
    @required void Function(QChatRoom, Exception) callback,
  }) {
    Future.sync(() async {
      await _authenticated;
      var res = await _room$$.createGroup(
        name: name,
        userIds: userIds,
        avatarUrl: avatarUrl,
        extras: extras,
      );
      return res.toModel();
    }).toCallback2(callback);
  }

  void deleteMessages({
    @required List<String> messageUniqueIds,
    @required void Function(List<QMessage>, Exception) callback,
  }) {
    final deleteMessages = __<DeleteMessageUseCase>();
    Future.sync(() async {
      await _authenticated;
      var res = await deleteMessages(DeleteMessageParams(messageUniqueIds));
      return res.map((it) => it.toModel()).toList();
    }).toCallback2(callback);
  }

  void enableDebugMode({
    @required bool enable,
    QLogLevel level = QLogLevel.log,
  }) {
    __<Storage>()
      ..debugEnabled = enable
      ..logLevel = level;
  }

  void getAllChatRooms({
    bool showParticipant,
    bool showRemoved,
    bool showEmpty,
    int limit,
    int page,
    @required void Function(List<QChatRoom>, Exception) callback,
  }) {
    Future.sync(() async {
      await _authenticated;
      var res = await _room$$.getAllRooms(
        withParticipants: showParticipant,
        withRemovedRoom: showRemoved,
        withEmptyRoom: showEmpty,
        limit: limit,
        page: page,
      );
      return res.map((r) => r.toModel()).toList();
    }).toCallback2(callback);
  }

  void getBlockedUsers({
    int page,
    int limit,
    @required void Function(List<QUser>, Exception) callback,
  }) {
    final params = GetBlockedUserParams(page: page, limit: limit);
    final useCase = __<GetBlockedUserUseCase>();

    Future.sync(() async {
      await _authenticated;
      var res = await useCase(params);
      return res.map((u) => u.toModel()).toList();
    }).toCallback2(callback);
  }

  void getChannel({
    @required String uniqueId,
    @required void Function(QChatRoom, Exception) callback,
  }) {
    Future.sync(() async {
      await _authenticated;
      var res = await _room$$.getOrCreateChannel(uniqueId: uniqueId);
      return res.toModel();
    }).toCallback2(callback);
  }

  void getChatRooms({
    List<int> roomIds,
    List<String> uniqueIds,
    int page,
    bool showRemoved,
    bool showParticipants,
    @required void Function(List<QChatRoom>, Exception) callback,
  }) {
    const ExceptionMessage = 'Please specify either `roomIds` or `uniqueIds`';

    Future.sync(() async {
      if ([roomIds, uniqueIds].every((it) => it == null)) {
        throw ArgumentError(ExceptionMessage);
      }
      if ([roomIds, uniqueIds].every((it) => it != null)) {
        throw ArgumentError(ExceptionMessage);
      }

      await _authenticated;
      var res = await _room$$.getRoomInfo(
        roomIds: roomIds,
        uniqueIds: uniqueIds,
        withRemoved: showRemoved,
        withParticipants: showParticipants,
        page: page,
      );
      return res.map((r) => r.toModel()).toList();
    }).toCallback2(callback);
  }

  void getChatRoomWithMessages({
    @required int roomId,
    @required void Function(QChatRoom, List<QMessage>, Exception) callback,
  }) {
    Future.sync(() async {
      await _authenticated;
      var data = await _room$$.getRoomWithId(roomId);
      var room = data.first.toModel();
      var messages = data.second.map((it) => it.toModel()).toList();
      return Tuple2(room, messages);
    }).toCallback2((data, error) {
      callback(data?.first, data?.second, error);
    });
  }

  void getJWTNonce({void Function(String, Exception) callback}) {
    Future.sync(() async {
      var res = await __<GetNonceUseCase>().call(noParams);
      return res;
    }).toCallback2(callback);
  }

  void getNextMessagesById({
    @required int roomId,
    @required int messageId,
    int limit,
    @required void Function(List<QMessage>, Exception) callback,
  }) {
    final useCase = __<GetMessageListUseCase>();
    final params =
        GetMessageListParams(roomId, messageId, after: true, limit: limit);

    Future.sync(() async {
      await _authenticated;
      var res = await useCase(params);
      return res.map((it) => it.toModel()).toList();
    }).toCallback2(callback);
  }

  void getParticipants({
    @required String roomUniqueId,
    int page,
    int limit,
    String sorting,
    @required void Function(List<QParticipant>, Exception) callback,
  }) {
    Future.sync(() async {
      await _authenticated;
      var res = await _room$$.getParticipants(
        roomUniqueId,
        page: page,
        limit: limit,
      );
      return res.map((r) => r.toModel()).toList();
    }).toCallback2(callback);
  }

  void getPreviousMessagesById({
    @required int roomId,
    int limit,
    int messageId,
    @required void Function(List<QMessage>, Exception) callback,
  }) {
    _authenticated
        .chain(__<GetMessageListUseCase>()(
          GetMessageListParams(roomId, messageId, after: false, limit: limit),
        ))
        .then((r) => r.map((m) => m.toModel()).toList())
        .toCallback2(callback);
  }

  String getThumbnailURL(String url) => url;

  void getTotalUnreadCount({@required void Function(int, Exception) callback}) {
    _authenticated.chain(_room$$.getTotalUnreadCount()).toCallback2(callback);
  }

  void getUserData({@required void Function(QAccount, Exception) callback}) {
    var useCase = __<GetUserDataUseCase>();
    _authenticated
        .chain(useCase(noParams))
        .then((u) => u.toModel())
        .toCallback2(callback);
  }

  void getUsers({
    @deprecated String searchUsername,
    int page,
    int limit,
    @required void Function(List<QUser>, Exception) callback,
  }) {
    final params = GetUserParams(
      query: searchUsername,
      page: page,
      limit: limit,
    );
    final getUsers = __<GetUsersUseCase>();
    _authenticated
        .chain(getUsers(params))
        .then((u) => u.map((u) => u.toModel()).toList())
        .toCallback2(callback);
  }

  void hasSetupUser({
    @required void Function(bool) callback,
  }) {
    callback(currentUser != null);
  }

  void intercept({
    @required String interceptor,
    @required Future<QMessage> Function(QMessage) callback,
  }) {
    // FIXME: Work on this thing!
  }

  void markAsDelivered({
    @required int roomId,
    @required int messageId,
    @required void Function(Exception) callback,
  }) {
    _authenticated
        .chain(__<UpdateMessageStatusUseCase>()(UpdateStatusParams(
          roomId,
          messageId,
          QMessageStatus.delivered,
        )))
        .then((_) => null)
        .toCallback1(callback);
  }

  void markAsRead({
    @required int roomId,
    @required int messageId,
    @required void Function(Exception) callback,
  }) {
    _authenticated
        .chain(__<UpdateMessageStatusUseCase>()(UpdateStatusParams(
          roomId,
          messageId,
          QMessageStatus.read,
        )))
        .toCallback1(callback);
  }

  SubscriptionFn onChatRoomCleared(void Function(int) handler) {
    var params = TokenParams(__<Storage>()?.token);
    var ret = _authenticated
        .chain(__<OnRoomMessagesCleared>().subscribe(params))
        .then((s) => s.where((r) => r.toNullable() != null))
        .then((s) => s.listen((it) => handler(it.toNullable())));

    return () => ret.then<void>((s) => s.cancel());
  }

  SubscriptionFn onConnected(void Function() handler) {
    var ret = _authenticated
        .chain(__<OnConnected>().subscribe(noParams))
        .then((stream) => stream.listen((_) => handler()));
    return () => ret.then<void>((s) => s.cancel());
  }

  SubscriptionFn onDisconnected(void Function() handler) {
    var ret = _authenticated
        .chain(__<OnDisconnected>().subscribe(noParams))
        .then((s) => s.listen((_) => handler()));

    return () => ret.then<void>((s) => s.cancel());
  }

  SubscriptionFn onMessageDeleted(void Function(QMessage) callback) {
    var subs = _authenticated
        .chain(__<OnMessageDeleted>().subscribe(TokenParams(token)))
        .then((stream) => stream.listen((m) => callback(m.toModel())));

    return () => subs.then<void>((s) => s.cancel());
  }

  SubscriptionFn onMessageDelivered(void Function(QMessage) callback) {
    final subs = _authenticated
        .chain(__<OnMessageDelivered>().listen((m) => callback(m.toModel())));
    return () => subs.then<void>((s) => s.cancel());
  }

  SubscriptionFn onMessageRead(void Function(QMessage) callback) {
    final subs = _authenticated
        .chain(__<OnMessageRead>().listen((m) => callback(m.toModel())));

    return () => subs.then<void>((s) => s.cancel());
  }

  SubscriptionFn onMessageReceived(void Function(QMessage) callback) {
    var subs = _authenticated
        .chain(Future.value(__<Storage>().token))
        .then((t) => TokenParams(t))
        .then((token) => __<OnMessageReceived>().subscribe(token))
        .then((s) => s.listen((m) => callback(m.toModel())));

    return () => subs.then<void>((s) => s.cancel());
  }

  SubscriptionFn onMessageUpdated(void Function(QMessage) callback) {
    var subs = _authenticated
        .chain(__<OnMessageUpdated>().listen((m) => callback(m.toModel())));

    return () => subs.then<void>((s) => s.cancel());
  }

  SubscriptionFn onReconnecting(void Function() handler) {
    var ret = _authenticated
        .chain(__<OnReconnecting>().subscribe(noParams))
        .then((s) => s.listen((_) => handler()));

    return () => ret.then<void>((s) => s.cancel());
  }

  SubscriptionFn onUserOnlinePresence(
    void Function(String, bool, DateTime) handler,
  ) {
    final subs = _authenticated.chain(__<PresenceUseCase>().listen(
      (data) => handler(data.userId, data.isOnline, data.lastSeen),
    ));
    return () => subs.then<void>((s) => s.cancel());
  }

  SubscriptionFn onUserTyping(void Function(String, int, bool) handler) {
    var subs = _authenticated.chain(__<TypingUseCase>().listen((data) {
      handler(data.userId, data.roomId, data.isTyping);
    }));
    return () => subs.then<void>((s) => s.cancel());
  }

  void publishCustomEvent({
    @required int roomId,
    @required Map<String, dynamic> payload,
    @required void Function(Exception) callback,
  }) {
    _authenticated
        .chain(
          __<CustomEventUseCase>()(CustomEvent(
            roomId: roomId,
            payload: payload,
          )),
        )
        .toCallback1(callback);
  }

  void publishOnlinePresence({
    @required bool isOnline,
    @required void Function(Exception) callback,
  }) {
    _authenticated
        .chain(__<PresenceUseCase>()(UserPresence(
          userId: __<Storage>().userId,
          isOnline: isOnline,
          lastSeen: DateTime.now(),
        )))
        .toCallback1(callback);
  }

  void publishTyping({
    @required int roomId,
    bool isTyping,
  }) {
    _authenticated.chain(__<TypingUseCase>()(UserTyping(
      userId: __<Storage>().userId,
      roomId: roomId,
      isTyping: isTyping,
    )));
  }

  void registerDeviceToken({
    @required String token,
    bool isDevelopment,
    @required void Function(bool, Exception) callback,
  }) {
    var useCase = __<RegisterDeviceTokenUseCase>();
    var params = DeviceTokenParams(token, isDevelopment);
    return _authenticated.chain(useCase(params)).toCallback2(callback);
  }

  void removeDeviceToken({
    @required String token,
    bool isDevelopment,
    @required void Function(bool, Exception) callback,
  }) {
    var useCase = __<UnregisterDeviceTokenUseCase>();
    var params = DeviceTokenParams(token, isDevelopment);
    return _authenticated.chain(useCase(params)).toCallback2(callback);
  }

  void removeParticipants({
    @required int roomId,
    @required List<String> userIds,
    @required void Function(List<String>, Exception) callback,
  }) {
    _authenticated
        .chain(_room$$.removeParticipant(roomId, userIds))
        .toCallback2(callback);
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
    @required void Function(QMessage, Exception) callback,
  }) {
    _authenticated
        .chain(Future.sync(() {
          message.sender = __<Storage>().currentUser?.toModel()?.asUser();
          return message;
        }))
        .then((message) => __<SendMessageUseCase>()(MessageParams(message)))
        .then((it) => it.toModel())
        .toCallback2(callback);
  }

  void setCustomHeader(Map<String, String> headers) {
    __<Storage>().customHeaders = headers;
  }

  /// Set [period] (in milliseconds) in which sync and sync_event run
  void setSyncInterval(double period) {
    __<Storage>().syncInterval = period.ceil().milliseconds;
  }

  void setup(
    String appId, {
    @required void Function(Exception) callback,
  }) {
    setupWithCustomServer(appId, callback: callback);
  }

  void setupWithCustomServer(
    String appId, {
    String baseUrl = Storage.defaultBaseUrl,
    String brokerUrl = Storage.defaultBrokerUrl,
    String brokerLbUrl = Storage.defaultBrokerLbUrl,
    int syncInterval = Storage.defaultSyncInterval,
    int syncIntervalWhenConnected = Storage.defaultSyncIntervalWhenConnected,
    @required void Function(Exception) callback,
  }) async {
    final storage = __<Storage>();
    storage
      ..appId = appId
      ..baseUrl = baseUrl
      ..brokerUrl = brokerUrl
      ..brokerLbUrl = brokerLbUrl
      ..syncInterval = syncInterval.milliseconds
      ..syncIntervalWhenConnected = syncIntervalWhenConnected.milliseconds;

    __<AppConfigUseCase>()(noParams).toCallback1(callback);
  }

  void setUser({
    @required String userId,
    @required String userKey,
    String username,
    String avatarUrl,
    Map<String, dynamic> extras,
    @required void Function(QAccount, Exception) callback,
  }) {
    if (userId != null && userId.isEmpty) {
      throw ArgumentError.value(
          userId, 'userId', 'userId should not be empty string');
    }
    if (userKey != null && userKey.isEmpty) {
      throw ArgumentError.value(
          userKey, 'userKey', 'userKey should not be empty string');
    }

    final authenticate = __<AuthenticateUserUseCase>();
    final params = AuthenticateParams(
      userId: userId,
      userKey: userKey,
      name: username,
      avatarUrl: avatarUrl,
      extras: extras,
    );

    authenticate
        .call(params)
        .tap((_) => _connectMqtt())
        .then((it) => it.second.toModel())
        .toCallback2(callback);
  }

  void setUserWithIdentityToken({
    @required String token,
    @required void Function(QAccount, Exception) callback,
  }) {
    var authenticate = __<AuthenticateUserWithTokenUseCase>();
    var params = AuthenticateWithTokenParams(token);

    authenticate(params)
        .then((account) => Tuple2(token, account))
        .tap((_) => _connectMqtt())
        .then((it) => it.second.toModel())
        .toCallback2(callback);
  }

  void _connectMqtt() async {
    if (__<Storage>().isRealtimeEnabled) {
      await __<IRealtimeService>().connect();
    }
    final params = TokenParams(token);
    final onMessageReceived = __<OnMessageReceived>();
    final realtimeService = __<IRealtimeService>();
    final onMessageUpdated = __<OnMessageUpdated>();

    var stream = StreamGroup.merge<void>([
      onMessageReceived.subscribe(params).map((_) => null),
      onMessageUpdated.subscribe(params).map((_) => null),
      realtimeService.subscribe(TopicBuilder.notification(token)).asStream(),
    ]);

    await stream.first;
  }

  void unsubscribeChatRoom(QChatRoom room) {
    final params = RoomIdParams(room.id);

    final read = __<OnMessageRead>().unsubscribe(params);
    final delivered = __<OnMessageDelivered>().unsubscribe(params);
    final typing = __<TypingUseCase>().unsubscribe(UserTyping(
      roomId: room.id,
      userId: '+',
    ));

    _authenticated.chain(read).chain(delivered).chain(typing);
  }

  void subscribeChatRoom(QChatRoom room) {
    final params = RoomIdParams(room.id);

    final read = () => __<OnMessageRead>().subscribe(params);
    final delivered = () => __<OnMessageDelivered>().subscribe(params);
    final typing = () => __<TypingUseCase>().subscribe(UserTyping(
          roomId: room.id,
          userId: '+',
        ));
    _authenticated.chain(read()).chain(delivered()).chain(typing());
  }

  void subscribeCustomEvent({
    @required int roomId,
    @required void Function(Map<String, dynamic>) callback,
  }) {
    _authenticated
        .chain(__<CustomEventUseCase>().subscribe(RoomIdParams(roomId)))
        .then((stream) => stream.listen((data) => callback(data.payload)))
        .toCallback1((_) {});
  }

  void subscribeUserOnlinePresence(String userId) {
    _authenticated
        .chain(__<PresenceUseCase>().subscribe(UserPresence(userId: userId)))
        .toCallback1((err) {
      if (err != null) {
        __<Logger>().log('failed subscribing user online presence: $err');
      }
    });
  }

  void synchronize({String lastMessageId}) {
    _authenticated
        .chain(__<IRealtimeService>().synchronize(int.parse(lastMessageId)))
        .toCallback1((_) {});
  }

  void synchronizeEvent({String lastEventId}) {
    _authenticated
        .chain(__<IRealtimeService>().synchronizeEvent(lastEventId))
        .toCallback1((_) {});
  }

  void unblockUser({
    @required String userId,
    @required void Function(QUser, Exception) callback,
  }) {
    _authenticated
        .chain(__<UnblockUserUseCase>().call(UnblockUserParams(userId)))
        .then((u) => u.toModel())
        .toCallback2(callback);
  }

  void unsubscribeCustomEvent({@required int roomId}) {
    _authenticated
        .chain(__<CustomEventUseCase>().unsubscribe(RoomIdParams(roomId)))
        .toCallback1((_) {});
  }

  void unsubscribeUserOnlinePresence(String userId) {
    _authenticated
        .chain(__<PresenceUseCase>().unsubscribe(UserPresence(userId: userId)))
        .toCallback1((_) {});
  }

  void updateChatRoom({
    int roomId,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
    @required void Function(QChatRoom, Exception) callback,
  }) {
    _authenticated
        .chain(_room$$.updateRoom(
          roomId: roomId,
          name: name,
          avatarUrl: avatarUrl,
          extras: extras,
        ))
        .then((r) => r.toModel())
        .toCallback2(callback);
  }

  void updateUser({
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
    @required void Function(QAccount, Exception) callback,
  }) {
    var useCase = __<UpdateUserUseCase>();
    var params = UpdateUserParams(
      name: name,
      avatarUrl: avatarUrl,
      extras: extras,
    );
    _authenticated
        .chain(useCase(params))
        .then((u) => u.toModel())
        .toCallback2(callback);
  }

  void updateMessage({
    @required QMessage message,
    @required void Function(Exception) callback,
  }) {
    var useCase = __<UpdateMessageUseCase>();
    var params = MessageParams(message);
    _authenticated.chain(useCase(params)).toCallback1(callback);
  }

  void upload({
    @required File file,
    @required void Function(Exception, double, String) callback,
  }) async {
    final uploadUrl = __<Storage>().uploadUrl;
    final dio = __<Dio>();
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
      callback(error as Exception, null, null);
    });
  }

  void getFileList({
    List<int> roomIds,
    String fileType,
    List<String> includeExtensions,
    List<String> excludeExtensions,
    String userId,
    int page,
    int limit,
    @required void Function(List<QMessage>, Exception) callback,
  }) async {
    _authenticated
        .chain(__<MessageRepository>().getFileList(
          roomIds: roomIds,
          fileType: fileType,
          userId: userId,
          includeExtensions: includeExtensions,
          excludeExtensions: excludeExtensions,
          page: page,
          limit: limit,
        ))
        .then((it) => it.toList())
        .toCallback2(callback);
  }

  void closeRealtimeConnection(
    void Function(bool) callback,
  ) async {
    try {
      await _authenticated;
      await __<IRealtimeService>().closeConnection();
      callback(true);
    } catch (_) {
      callback(false);
    }
  }
  void openRealtimeConnection(void Function(bool) callback) async {
    try {
      await _authenticated;
      await __<IRealtimeService>().openConnection();
      callback(true);
    } catch (_) {
      callback(false);
    }
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
