library qiscus_chat_sdk;

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/widgets.dart' hide Interval, Notification;
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

  static Future<QiscusSDK> withAppId(String appId) async {
    var qiscus = QiscusSDK();
    await qiscus.setup(appId);
    return qiscus;
  }

  static Future<QiscusSDK> withCustomServer(
    String appId, {
    String baseUrl = Storage.defaultBaseUrl,
    String brokerUrl = Storage.defaultBrokerUrl,
    String brokerLbUrl = Storage.defaultBrokerLbUrl,
    int syncInterval = Storage.defaultSyncInterval,
    int syncIntervalWhenConnected = Storage.defaultSyncIntervalWhenConnected,
  }) async {
    var qiscus = QiscusSDK();
    await qiscus.setupWithCustomServer(
      appId,
      baseUrl: baseUrl,
      brokerUrl: brokerUrl,
      brokerLbUrl: brokerLbUrl,
      syncInterval: syncInterval,
      syncIntervalWhenConnected: syncIntervalWhenConnected,
    );

    return qiscus;
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

  void addHttpInterceptors(
      RequestOptions Function(RequestOptions, RequestInterceptorHandler)
          onRequest) {
    __<Dio>().interceptors.add(InterceptorsWrapper(
          onRequest: onRequest,
        ));
  }

  Future<List<QParticipant>> addParticipants({
    @required int roomId,
    @required List<String> userIds,
  }) async {
    var res = await _room$$.addParticipant(roomId, userIds);
    return res.map((m) => m.toModel()).toList();
  }

  Future<QUser> blockUser({
    @required String userId,
  }) async {
    final blockUser = __<BlockUserUseCase>();

    await _authenticated;
    var res = await blockUser(BlockUserParams(userId));
    return res.toModel();
  }

  Future<QChatRoom> chatUser({
    @required String userId,
    Map<String, dynamic> extras,
  }) async {
    await _authenticated;
    var res = await _room$$.getRoomWithUserId(userId: userId, extras: extras);
    return res.toModel();
  }

  Future<void> clearMessagesByChatRoomId({
    @required List<String> roomUniqueIds,
  }) async {
    await _authenticated;
    return _room$$.clearMessages(uniqueIds: roomUniqueIds);
  }

  Future<void> clearUser() async {
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

    await _authenticated;
    await clearSubscription();
    __<Storage>().clear();
    await __<IRealtimeService>().end();
  }

  Future<QChatRoom> createChannel({
    @required String uniqueId,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  }) async {
    await _authenticated;
    var res = await _room$$.getOrCreateChannel(
      uniqueId: uniqueId,
      name: name,
      avatarUrl: avatarUrl,
      options: extras,
    );

    return res.toModel();
  }

  Future<QChatRoom> createGroupChat({
    @required String name,
    @required List<String> userIds,
    String avatarUrl,
    Map<String, dynamic> extras,
  }) async {
    await _authenticated;
    var res = await _room$$.createGroup(
      name: name,
      userIds: userIds,
      avatarUrl: avatarUrl,
      extras: extras,
    );
    return res.toModel();
  }

  Future<List<QMessage>> deleteMessages({
    @required List<String> messageUniqueIds,
  }) async {
    final deleteMessages = __<DeleteMessageUseCase>();
    await _authenticated;
    var res = await deleteMessages(DeleteMessageParams(messageUniqueIds));
    return res.map((it) => it.toModel()).toList();
  }

  void enableDebugMode({
    @required bool enable,
    QLogLevel level = QLogLevel.log,
  }) {
    __<Storage>()
      ..debugEnabled = enable
      ..logLevel = level;
  }

  Future<List<QChatRoom>> getAllChatRooms({
    bool showParticipant,
    bool showRemoved,
    bool showEmpty,
    int limit,
    int page,
  }) async {
    await _authenticated;
    var res = await _room$$.getAllRooms(
      withParticipants: showParticipant,
      withRemovedRoom: showRemoved,
      withEmptyRoom: showEmpty,
      limit: limit,
      page: page,
    );
    return res.map((r) => r.toModel()).toList();
  }

  Future<List<QUser>> getBlockedUsers({
    int page,
    int limit,
  }) async {
    final params = GetBlockedUserParams(page: page, limit: limit);
    final useCase = __<GetBlockedUserUseCase>();

    await _authenticated;
    var res = await useCase(params);
    return res.map((u) => u.toModel()).toList();
  }

  Future<QChatRoom> getChannel({
    @required String uniqueId,
  }) async {
    await _authenticated;
    var res = await _room$$.getOrCreateChannel(uniqueId: uniqueId);
    return res.toModel();
  }

  Future<List<QChatRoom>> getChatRooms({
    List<int> roomIds,
    List<String> uniqueIds,
    int page,
    bool showRemoved,
    bool showParticipants,
  }) async {
    const ExceptionMessage = 'Please specify either `roomIds` or `uniqueIds`';

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
  }

  Future<QChatRoomWithMessages> getChatRoomWithMessages({
    @required int roomId,
  }) async {
    await _authenticated;
    var data = await _room$$.getRoomWithId(roomId);
    var room = data.first.toModel();
    var messages = data.second.map((it) => it.toModel()).toList();
    return QChatRoomWithMessages(room, messages);
  }

  Future<String> getJWTNonce() async {
    var res = await __<GetNonceUseCase>().call(noParams);
    return res;
  }

  Future<List<QMessage>> getNextMessagesById({
    @required int roomId,
    @required int messageId,
    int limit,
  }) async {
    final useCase = __<GetMessageListUseCase>();
    final params =
        GetMessageListParams(roomId, messageId, after: true, limit: limit);

    await _authenticated;
    var res = await useCase(params);
    return res.map((it) => it.toModel()).toList();
  }

  Future<List<QParticipant>> getParticipants({
    @required String roomUniqueId,
    int page,
    int limit,
    String sorting,
  }) async {
    await _authenticated;
    var res = await _room$$.getParticipants(
      roomUniqueId,
      page: page,
      limit: limit,
    );
    return res.map((r) => r.toModel()).toList();
  }

  Future<List<QMessage>> getPreviousMessagesById({
    @required int roomId,
    int limit,
    int messageId,
  }) {
    return _authenticated
        .chain(__<GetMessageListUseCase>()(
          GetMessageListParams(roomId, messageId, after: false, limit: limit),
        ))
        .then((r) => r.map((m) => m.toModel()).toList());
  }

  String getThumbnailURL(String url) => url;

  Future<int> getTotalUnreadCount() {
    return _authenticated.chain(_room$$.getTotalUnreadCount());
  }

  Future<QAccount> getUserData() async {
    var useCase = __<GetUserDataUseCase>();
    return _authenticated
        .chain(useCase(noParams))
        .then((u) => u.toModel());
  }

  Future<List<QUser>> getUsers({
    @deprecated String searchUsername,
    int page,
    int limit,
  }) async {
    final params = GetUserParams(
      query: searchUsername,
      page: page,
      limit: limit,
    );
    final getUsers = __<GetUsersUseCase>();
    return _authenticated
        .chain(getUsers(params))
        .then((u) => u.map((u) => u.toModel()).toList());
  }

  Future<bool> hasSetupUser() async {
    return currentUser != null;
  }

  void intercept({
    @required String interceptor,
    @required Future<QMessage> Function(QMessage) callback,
  }) {
    // FIXME: Work on this thing!
  }

  Future<void> markAsDelivered({
    @required int roomId,
    @required int messageId,
  }) async {
    return _authenticated
        .chain(__<UpdateMessageStatusUseCase>()(UpdateStatusParams(
          roomId,
          messageId,
          QMessageStatus.delivered,
        )))
        .then((_) => null);
  }

  Future<void> markAsRead({
    @required int roomId,
    @required int messageId,
  }) async  {
    return _authenticated
        .chain(__<UpdateMessageStatusUseCase>()(UpdateStatusParams(
          roomId,
          messageId,
          QMessageStatus.read,
        )));
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

  Future<void> publishCustomEvent({
    @required int roomId,
    @required Map<String, dynamic> payload,
  }) {
    return _authenticated
        .chain(
          __<CustomEventUseCase>()(CustomEvent(
            roomId: roomId,
            payload: payload,
          )),
        );
  }

  Future<void> publishOnlinePresence({
    @required bool isOnline,
  }) {
    return _authenticated
        .chain(__<PresenceUseCase>()(UserPresence(
          userId: __<Storage>().userId,
          isOnline: isOnline,
          lastSeen: DateTime.now(),
        )));
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

  Future<bool> registerDeviceToken({
    @required String token,
    bool isDevelopment,
  }) {
    var useCase = __<RegisterDeviceTokenUseCase>();
    var params = DeviceTokenParams(token, isDevelopment);
    return _authenticated.chain(useCase(params));
  }

  Future<bool> removeDeviceToken({
    @required String token,
    bool isDevelopment,
  }) {
    var useCase = __<UnregisterDeviceTokenUseCase>();
    var params = DeviceTokenParams(token, isDevelopment);
    return _authenticated.chain(useCase(params));
  }

  Future<List<String>> removeParticipants({
    @required int roomId,
    @required List<String> userIds,
  }) async {
    return _authenticated
        .chain(_room$$.removeParticipant(roomId, userIds));
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

        try {
          var msg = await sendMessage(message: message);
          callback(null, null, msg);
        } on Exception catch (error) {
          callback(error, null, null);
        }
      },
    );
  }

  Future<QMessage> sendMessage({
    @required QMessage message,
  }) async {
    return _authenticated
        .chain(Future.sync(() {
          message.sender = __<Storage>().currentUser?.toModel()?.asUser();
          return message;
        }))
        .then((message) => __<SendMessageUseCase>()(MessageParams(message)))
        .then((it) => it.toModel());
  }

  void setCustomHeader(Map<String, String> headers) {
    __<Storage>().customHeaders = headers;
  }

  /// Set [period] (in milliseconds) in which sync and sync_event run
  void setSyncInterval(double period) {
    __<Storage>().syncInterval = period.ceil().milliseconds;
  }

  Future<void> setup(String appId) async {
    return setupWithCustomServer(appId);
  }

  Future<void> setupWithCustomServer(
    String appId, {
    String baseUrl = Storage.defaultBaseUrl,
    String brokerUrl = Storage.defaultBrokerUrl,
    String brokerLbUrl = Storage.defaultBrokerLbUrl,
    int syncInterval = Storage.defaultSyncInterval,
    int syncIntervalWhenConnected = Storage.defaultSyncIntervalWhenConnected,
  }) async {
    final storage = __<Storage>();
    storage
      ..appId = appId
      ..baseUrl = baseUrl
      ..brokerUrl = brokerUrl
      ..brokerLbUrl = brokerLbUrl
      ..syncInterval = syncInterval.milliseconds
      ..syncIntervalWhenConnected = syncIntervalWhenConnected.milliseconds;

    var config = await __<AppConfigUseCase>()(noParams);
    storage
      ..baseUrl = config.baseUrl.getOrElse(() => storage.baseUrl)
      ..brokerUrl = config.brokerUrl.getOrElse(() => storage.brokerUrl)
      ..brokerLbUrl = config.brokerLbUrl.getOrElse(() => storage.brokerLbUrl)
      ..syncInterval = config.syncInterval
          .map((it) => Duration(milliseconds: it))
          .getOrElse(() => storage.syncInterval)
      ..syncIntervalWhenConnected = config.syncOnConnect
          .map((it) => Duration(milliseconds: it))
          .getOrElse(() => storage.syncIntervalWhenConnected);
  }

  Future<QAccount> setUser({
    @required String userId,
    @required String userKey,
    String username,
    String avatarUrl,
    Map<String, dynamic> extras,
  }) async {
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

    return authenticate
        .call(params)
        .tap((_) => _connectMqtt())
        .then((it) => it.second.toModel());
  }

  Future<QAccount> setUserWithIdentityToken({
    @required String token,
  }) {
    var authenticate = __<AuthenticateUserWithTokenUseCase>();
    var params = AuthenticateWithTokenParams(token);

    return authenticate(params)
        .then((account) => Tuple2(token, account))
        .tap((_) => _connectMqtt())
        .then((it) => it.second.toModel());
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

  Future<QUser> unblockUser({
    @required String userId,
  }) async {
    return _authenticated
        .chain(__<UnblockUserUseCase>().call(UnblockUserParams(userId)))
        .then((u) => u.toModel());
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

  Future<QChatRoom> updateChatRoom({
    int roomId,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  }) async {
    return _authenticated
        .chain(_room$$.updateRoom(
          roomId: roomId,
          name: name,
          avatarUrl: avatarUrl,
          extras: extras,
        ))
        .then((r) => r.toModel());
  }

  Future<QAccount> updateUser({
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  }) {
    var useCase = __<UpdateUserUseCase>();
    var params = UpdateUserParams(
      name: name,
      avatarUrl: avatarUrl,
      extras: extras,
    );
    return _authenticated.chain(useCase(params)).then((u) => u.toModel());
  }

  Future<void> updateMessage({
    @required QMessage message,
  }) async {
    var useCase = __<UpdateMessageUseCase>();
    var params = MessageParams(message);
    await _authenticated.chain(useCase.call(params));
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

  Future<List<QMessage>> getFileList({
    List<int> roomIds,
    String fileType,
    List<String> includeExtensions,
    List<String> excludeExtensions,
    String userId,
    int page,
    int limit,
  }) async {
    return _authenticated
        .chain(__<MessageRepository>().getFileList(
          roomIds: roomIds,
          fileType: fileType,
          userId: userId,
          includeExtensions: includeExtensions,
          excludeExtensions: excludeExtensions,
          page: page,
          limit: limit,
        ))
        .then((it) => it.toList());
  }

  Future<bool> closeRealtimeConnection() async {
    try {
      await _authenticated;
      await __<IRealtimeService>().closeConnection();

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> openRealtimeConnection() async {
    try {
      await _authenticated;
      await __<IRealtimeService>().openConnection();
      return true;
    } catch (_) {
      return false;
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

class QChatRoomWithMessages {
  const QChatRoomWithMessages(this.room, this.messages);

  final QChatRoom room;
  final List<QMessage> messages;
}

class QUserPresence with EquatableMixin {
  String userId;
  bool isOnline;
  DateTime lastOnline;

  @override
  List<Object> get props => [userId, isOnline, lastOnline];
  @override
  bool get stringify => true;
}

class QUserTyping with EquatableMixin {
  String userId;
  int roomId;
  bool isTyping;

  @override
  List<Object> get props => [userId, roomId, isTyping];
  @override
  bool get stringify => true;
}
