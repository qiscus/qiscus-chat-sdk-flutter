library qiscus_chat_sdk;

import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/features/channel/usecase/create.dart';

import 'core/core.dart';
import 'core/injector.dart';
import 'features/core/core.dart';
import 'features/custom_event/usecase/realtime.dart';
import 'features/realtime/realtime.dart';
import 'features/user/user.dart';
import 'features/room/room.dart';
import 'features/message/message.dart';

typedef Subscription = void Function();
typedef UserPresenceHandler = void Function(String, bool, DateTime);
typedef UserTypingHandler = void Function(String, int, bool);

class QiscusSDK {
  static final instance = QiscusSDK();

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

  String get appId => _get<Storage>()?.appId;

  QAccount get currentUser => _get<Storage>()?.currentUser?.toModel();

  bool get isLogin => _get<Storage>()?.currentUser != null;

  String get token => _get<Storage>()?.token;

  Task<Either<Exception, void>> get _authenticated {
    final _isLogin = Stream<void>.periodic(const Duration(milliseconds: 300))
        .map((_) => isLogin)
        .distinct((p, n) => p == n)
        .firstWhere((it) => it == true);
    return Task(() => _isLogin).attempt().leftMapToException('Not logged in');
  }

  void addHttpInterceptors(RequestOptions Function(RequestOptions) onRequest) {
    _get<Dio>().interceptors.add(InterceptorsWrapper(
          onRequest: onRequest,
        ));
  }

  void addParticipants({
    @required int roomId,
    @required List<String> userIds,
    @required void Function(List<QParticipant>, Exception) callback,
  }) {
    final addParticipant = _get<AddParticipantUseCase>();
    _authenticated
        .andThen(addParticipant(ParticipantParams(roomId, userIds)))
        .rightMap((r) => r.map((m) => m.toModel()).toList())
        .toCallback(callback)
        .run();
  }

  void blockUser({
    @required String userId,
    @required void Function(QUser, Exception) callback,
  }) {
    final blocUser = _get<BlockUserUseCase>();
    _authenticated
        .andThen(blocUser(BlockUserParams(userId)))
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
        .andThen(_get<GetRoomByUserIdUseCase>()(UserIdParams(userId)))
        .rightMap((u) => u.toModel())
        .toCallback(callback)
        .run();
  }

  void clearMessagesByChatRoomId({
    @required List<String> roomUniqueIds,
    @required void Function(Exception) callback,
  }) {
    final clearRoom = _get<ClearRoomMessagesUseCase>();
    _authenticated
        .andThen(clearRoom(ClearRoomMessagesParams(roomUniqueIds)))
        .toCallback((_, e) => callback(e))
        .run();
  }

  void clearUser({
    @required void Function(Exception) callback,
  }) {
    _authenticated
        .andThen(Task.delay(() {
          _get<Storage>().clear();
          _get<RealtimeService>('mqtt-service').end();
          _get<RealtimeService>('mqtt-service').end();
        }))
        .run()
        .catchError((Exception error) {
          callback(error);
        });
  }

  void createChannel({
    @required String uniqueId,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
    @required void Function(QChatRoom, Exception) callback,
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
        .toCallback(callback)
        .run();
  }

  void createGroupChat({
    @required String name,
    @required List<String> userIds,
    String avatarUrl,
    Map<String, dynamic> extras,
    @required void Function(QChatRoom, Exception) callback,
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
        .toCallback(callback)
        .run();
  }

  void deleteMessages({
    @required List<String> messageUniqueIds,
    @required void Function(List<QMessage>, Exception) callback,
  }) {
    final useCase = _get<DeleteMessageUseCase>();
    _authenticated
        .andThen(useCase(DeleteMessageParams(messageUniqueIds)))
        .rightMap((it) => it.map((i) => i.toModel()).toList())
        .toCallback(callback)
        .run();
  }

  void enableDebugMode({bool enable = false}) {
    _get<Storage>().debugEnabled = enable;
  }

  void getAllChatRooms({
    bool showParticipant,
    bool showRemoved,
    bool showEmpty,
    int limit,
    int page,
    @required void Function(List<QChatRoom>, Exception) callback,
  }) {
    final useCase = _get<GetAllRoomsUseCase>();
    _authenticated
        .andThen(useCase(GetAllRoomsParams(
          withParticipants: showParticipant,
          withRemovedRoom: showRemoved,
          withEmptyRoom: showEmpty,
          limit: limit,
          page: page,
        )))
        .rightMap((r) => r.map((c) => c.toModel()).toList())
        .toCallback(callback)
        .run();
  }

  final _get = Injector.get;

  void getBlockedUsers({
    int page,
    int limit,
    @required void Function(List<QUser>, Exception) callback,
  }) {
    _authenticated
        .andThen(_get<GetBlocedUserUseCase>().call(
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
  }) {
    _authenticated
        .andThen(_get<GetOrCreateChannelUseCase>()(GetOrCreateChannelParams(
          uniqueId,
        )))
        .rightMap((room) => room.toModel())
        .toCallback(callback)
        .run();
  }

  void getChatRooms({
    List<int> roomIds,
    List<String> uniqueIds,
    int page,
    bool showRemoved,
    bool showParticipants,
    @required void Function(List<QChatRoom>, Exception) callback,
  }) {
    const errorMessage = 'Please specify either `roomIds` or `uniqueIds`';
    // Throw error if both roomIds and uniqueIds are null
    assert(roomIds == null && uniqueIds == null, errorMessage);
    assert(roomIds != null && uniqueIds != null, errorMessage);

    _authenticated
        .andThen(_get<GetRoomInfoUseCase>()(GetRoomInfoParams(
          roomIds: roomIds,
          uniqueIds: uniqueIds,
          withRemoved: showRemoved,
          withParticipants: showParticipants,
          page: page,
        )))
        .rightMap((r) => r.map((it) => it.toModel()).toList())
        .toCallback(callback)
        .run();
  }

  void getChatRoomWithMessages({
    @required int roomId,
    @required void Function(QChatRoom, List<QMessage>, Exception) callback,
  }) {
    _authenticated
        .andThen(_get<GetRoomWithMessagesUseCase>()(RoomIdParams(roomId)))
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
    _get<GetNonceUseCase>()(NoParams()).toCallback(callback).run();
  }

  void getNextMessagesById({
    @required int roomId,
    @required int messageId,
    int limit,
    @required void Function(List<QMessage>, Exception) callback,
  }) {
    _authenticated
        .andThen(_get<GetMessageListUseCase>()(
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
        .andThen(
            _get<GetParticipantsUseCase>()(RoomUniqueIdsParams(roomUniqueId)))
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
        .andThen(_get<GetMessageListUseCase>()(
          GetMessageListParams(roomId, messageId, after: false, limit: limit),
        ))
        .rightMap((it) => it.map((m) => m.toModel()).toList())
        .toCallback(callback)
        .run();
  }

  String getThumbnailURL(String url) => '';

  void getTotalUnreadCount({
    @required void Function(int, Exception) callback,
  }) {
    _authenticated
        .andThen(_get<GetTotalUnreadCountUseCase>()(noParams))
        .toCallback(callback)
        .run();
  }

  void getUserData({
    void Function(QAccount, Exception) callback,
  }) {
    _authenticated
        .andThen(_get<GetUserDataUseCase>().call(NoParams()))
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
        .andThen(_get<GetUsersUseCase>().call(GetUserParams(
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
        .andThen(_get<UpdateMessageStatusUseCase>()(UpdateStatusParams(
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
        .andThen(_get<UpdateMessageStatusUseCase>()(UpdateStatusParams(
          roomId,
          messageId,
          QMessageStatus.read,
        )))
        .toCallback((_, e) => callback(e))
        .run();
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
        .andThen(_get<OnConnected>().subscribe(NoParams()))
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
    var listenable =
        _get<OnMessageReceived>().listen((m) => callback(m.toModel()));

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
    @required void Function(Exception) callback,
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
    @required void Function(Exception) callback,
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

  void registerDeviceToken({
    @required String token,
    bool isDevelopment,
    void Function(bool, Exception) callback,
  }) {
    _authenticated
        .andThen(_get<RegisterDeviceTokenUseCase>()(DeviceTokenParams(
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
        .andThen(_get<UnregisterDeviceTokenUseCase>()(DeviceTokenParams(
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
        .andThen(_get<RemoveParticipantUseCase>()(
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
        message.payload ??= <String, dynamic>{};
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
    _authenticated
        .andThen(_get<SendMessageUseCase>().call(MessageParams(message)))
        .rightMap((it) => it.toModel())
        .toCallback(callback)
        .run();
  }

  void setCustomHeader(Map<String, String> headers) {
    _get<Storage>().customHeaders = headers;
  }

  void setSyncInterval(double interval) {
    _get<Storage>().syncInterval = interval.ceil();
  }

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
    _get<AppConfigUseCase>()(noParams)
        .tap((_) {
          _get<Storage>().appId = appId;
          _get<Storage>().baseUrl = baseUrl;
          _get<Storage>().brokerUrl = brokerUrl;
          _get<Storage>().brokerLbUrl = brokerLbUrl;
          _get<Storage>().syncInterval = syncInterval;
          _get<Storage>().syncIntervalWhenConnected = syncIntervalWhenConnected;
        })
        .map((either) => either.fold(
              (err) => callback(err),
              (_) => callback(null),
            ))
        .run();
  }

  void setUser({
    @required String userId,
    @required String userKey,
    String username,
    String avatarUrl,
    Map<String, dynamic> extras,
    @required void Function(QAccount, Exception) callback,
  }) {
    var markAsDelivered = (Stream<Message> stream) => stream.tap(
          (m) => m.chatRoomId.fold(
            () {},
            (roomId) => this.markAsDelivered(
              roomId: roomId,
              messageId: m.id,
              callback: (_) {},
            ),
          ),
        );
    var subscribes = (String token) => _get<OnMessageReceived>()
        .subscribe(TokenParams(token))
        .bind((stream) => Task.delay(() => markAsDelivered(stream)))
        .andThen(_get<RealtimeService>()
            .subscribe(TopicBuilder.notification(token)));

    _get<AuthenticateUserUseCase>()(AuthenticateParams(
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
    _get<AuthenticateUserWithTokenUseCase>()
        .call(AuthenticateWithTokenParams(token))
        .rightMap((user) => user.toModel())
        .toCallback(callback)
        .run();
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
        .andThen(_get<RealtimeService>().synchronize(int.parse(lastMessageId)))
        .run()
        .catchError((dynamic _) {});
  }

  void synchronizeEvent({String lastEventId}) {
    _authenticated
        .andThen(_get<RealtimeService>().synchronizeEvent(lastEventId))
        .run()
        .catchError((dynamic _) {});
  }

  void unblockUser({
    @required String userId,
    @required void Function(QUser, Exception) callback,
  }) {
    _authenticated
        .andThen(_get<UnblockUserUseCase>().call(UnblockUserParams(userId)))
        .rightMap((u) => u.toModel())
        .toCallback(callback)
        .run();
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
    @required void Function(QChatRoom, Exception) callback,
  }) {
    _authenticated
        .andThen(_get<UpdateRoomUseCase>()(UpdateRoomParams(
          roomId: roomId,
          name: name,
          avatarUrl: avatarUrl,
          extras: extras,
        )))
        .rightMap((r) => r.toModel())
        .toCallback(callback)
        .run();
  }

  void updateUser({
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
    @required void Function(QAccount, Exception) callback,
  }) {
    _authenticated
        .andThen(_get<UpdateUserUseCase>()(UpdateUserParams(
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
