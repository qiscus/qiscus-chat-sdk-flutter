library qiscus_chat_sdk;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:riverpod/riverpod.dart';

import 'app_config/app_config.dart';
import 'core.dart';
import 'debug.dart';
import 'domain/commons.dart';
import 'domain/message/message-model.dart';
import 'domain/qiscus.dart';
import 'domain/room/room-model.dart';
import 'domain/user/user-model.dart';
import 'impls/message/delete-messages-impl.dart';
import 'impls/message/get-message-impl.dart';
import 'impls/message/on-message-deleted-impl.dart';
import 'impls/message/on-message-delivered-impl.dart';
import 'impls/message/on-message-read-impl.dart';
import 'impls/message/on-message-received-impl.dart';
import 'impls/message/on-message-updated-impl.dart';
import 'impls/message/send-message-impl.dart';
import 'impls/message/update-message-impl.dart';
import 'impls/message/update-message-status-impl.dart';
import 'impls/mqtt-impls.dart';
import 'impls/room/add-participants.dart';
import 'impls/room/chat-user-impl.dart';
import 'impls/room/clear-messages-impl.dart';
import 'impls/room/create-channel-impl.dart';
import 'impls/room/create-group-chat-impl.dart';
import 'impls/room/get-all-chat-rooms-impl.dart';
import 'impls/room/get-channel-impl.dart';
import 'impls/room/get-chat-rooms-impl.dart';
import 'impls/room/get-file-list-impl.dart';
import 'impls/room/get-participants-impl.dart';
import 'impls/room/get-room-with-messages-impl.dart';
import 'impls/room/get-total-unread-count-impl.dart';
import 'impls/room/on-room-cleared.dart';
import 'impls/room/publish-custom-event-impl.dart';
import 'impls/room/remove-participant-impl.dart';
import 'impls/room/update-chat-room-impl.dart';
import 'impls/sync.dart';
import 'impls/user/block-user-impl.dart';
import 'impls/user/get-blocked-users-impl.dart';
import 'impls/user/get-nonce-impl.dart';
import 'impls/user/get-user-data-impl.dart';
import 'impls/user/get-users-impl.dart';
import 'impls/user/is-authenticated-impl.dart';
import 'impls/user/on-user-presence-impl.dart';
import 'impls/user/on-user-typing-impl.dart';
import 'impls/user/publish-online-presence-impl.dart';
import 'impls/user/publish-user-typing-impl.dart';
import 'impls/user/register-device-token-impl.dart';
import 'impls/user/set-user-impl.dart';
import 'impls/user/unblock-user-impl.dart';
import 'impls/user/update-user-impl.dart';

typedef StateTransformer<T>
    = StreamTransformer<QMqttMessage, State<Iterable<T>, T>>;

class QiscusSDK implements IQiscusSDK {
  static final instance = QiscusSDK();
  final container = ProviderContainer();
  var _storage = Storage();
  Tuple2<MqttClient, Storage> get _deps => Tuple2(_mqtt, _storage);
  late final Logger _logger = Logger(_storage);
  late final Dio _dio = getDio.run(Tuple2(_storage, _logger));
  late final MqttClient _mqtt = getMqttClient(_storage);
  MqttClient get mqtt => _mqtt;
  String? get appId => _storage.appId;
  QAccount? get currentUser => _storage.currentUser;
  bool get isLogin => currentUser != null;
  String? get token => _storage.token;
  Storage get storage => _storage;
  static final _thumbnailURL = RegExp(
    r'^https?://\S+(/upload/)\S+(\.\w+)$',
    caseSensitive: false,
  );

  late final _mqttUpdates = mqttUpdates()
      .run(_mqtt)
      .run()
      .asBroadcastStream()
      .transform(mqttExpandTransformer);

  late final StreamTransformer<Unit, bool> _authenticatedTransformer =
      StreamTransformer.fromHandlers(handleData: (_, sink) async {
    var isLoggedIn = await waitTillAuthenticatedImpl.run(_deps).run();
    sink.add(isLoggedIn);
  });

  Duration _interval() {
    if (_storage.token == null) return _storage.syncInterval;
    return _mqtt.connectionStatus?.state == MqttConnectionState.connected
        ? _storage.syncIntervalWhenConnected
        : _storage.syncInterval;
  }

  Stream<Unit> _interval$() async* {
    var accumulator = 0.milliseconds;
    var acc$ = Stream.periodic(
      _storage.accSyncInterval,
      (_) => _storage.accSyncInterval,
    );

    await for (var it in acc$) {
      accumulator += it;
      var interval = _interval();
      var shouldSync = accumulator >= interval;

      if (shouldSync) {
        yield unit;
        accumulator = 0.milliseconds;
      }
    }
  }

  Stream<QMessage> _synchronize() async* {
    var stream = _interval$().transform<bool>(_authenticatedTransformer);

    await for (var _ in stream) {
      if (_storage.isSyncEnabled && isLogin) {
        try {
          var lastMessageId =
              _storage.currentUser?.lastMessageId ?? _storage.lastMessageId;
          var _data = await synchronizeImpl(lastMessageId.toString())
              .run(_dio)
              .runOrThrow();

          if (_data.second.isNotEmpty || _data.first != 0) {
            _storage.currentUser?.lastMessageId = _data.first;
            _storage.lastMessageId = _data.first;
          }
          for (var message in _data.second) {
            yield message;
          }
        } catch (_) {}
      }
    }
  }

  Stream<QRealtimeEvent> _synchronizeEvent() async* {
    var stream = _interval$().transform(_authenticatedTransformer);
    await for (var _ in stream) {
      if (_storage.isSyncEventEnabled && isLogin) {
        try {
          var lastEventId =
              _storage.currentUser?.lastEventId ?? _storage.lastEventId;
          var data =
              await synchronizeEventImpl(lastEventId).run(_dio).runOrThrow();

          if (data.second.isNotEmpty || data.first != 0) {
            _storage.currentUser?.lastEventId = data.first;
            _storage.lastEventId = data.first;
          }

          for (var event in data.second) {
            yield event;
          }
        } catch (_) {}
      }
    }
  }

  late final StreamController<QMessage> _messageReceivedSubs$ =
      StreamController();
  late final Stream<QMessage> _messageReceived$ = StreamGroup.mergeBroadcast([
    _messageReceivedSubs$.stream,
    _synchronize(),
    _mqttUpdates.transform(mqttMessageReceivedTransformer),
  ]).asyncMap((it) async {
    markAsDelivered(roomId: it.chatRoomId, messageId: it.id).ignore();
    return it;
  }).asyncMap((it) => _triggerHook(QInterceptor.messageBeforeReceived, it));

  late final Stream<QMessage> _messageRead$ = StreamGroup.mergeBroadcast([
    _synchronizeEvent().transform(syncMessageReadTransformerImpl),
    _mqttUpdates.transform(mqttMessageReadTransformerImpl),
  ])
      .map((it) => it.run(_storage.messages))
      .tap((it) => _storage.messages = it.second.toSet())
      .map((it) => it.first)
      .transform(nonNullTransformer());

  late final Stream<QMessage> _messageDelivered$ = StreamGroup.mergeBroadcast([
    _synchronizeEvent().transform(syncMessageDeliveredTransformerImpl),
    _mqttUpdates.transform(mqttMessageDeliveredTransformerImpl),
  ])
      .map((it) => it.run(_storage.messages))
      .tap((it) => _storage.messages = it.second.toSet())
      .map((it) => it.first)
      .transform(nonNullTransformer());

  late final Stream<QMessage> _messageDeleted$ = StreamGroup.mergeBroadcast([
    _synchronizeEvent().transform(syncMessageDeletedTransformerImpl),
    _mqttUpdates.transform(mqttMessageDeletedTransformerImpl)
  ])
      .map((state) => state.run(_storage.messages))
      .tap((it) => _storage.messages = it.second.toSet())
      .map((it) => it.first)
      .transform(nonNullTransformer());
  late final Stream<QMessage> _messageUpdated$ = _mqttUpdates
      .transform(mqttMessageUpdatedTransformerImpl)
      .map((state) => state.run(_storage.messages))
      .tap((it) => _storage.messages = it.second.toSet())
      .map((it) => it.first);
  late final Stream<QUserTyping> _userTyping$ =
      _mqttUpdates.transform(mqttUserTypingTransformerImpl);
  late final Stream<QUserPresence> _userPresence$ =
      _mqttUpdates.transform(mqttUserPresenceTransformerImpl);

  late final Stream<int> _roomCleared$ = StreamGroup.merge([
    _synchronizeEvent().transform(syncRoomClearedTransformerImpl),
    _mqttUpdates.transform(mqttRoomClearedTransformerImpl),
  ]);

  Stream<MqttConnectionState?> _connection$() async* {
    yield* Stream.periodic(
      const Duration(milliseconds: 300),
      (_) => _mqtt.connectionStatus?.state,
    ).distinct();
  }

  Stream<void> get _mqttDisconnected =>
      _connection$().where((it) => it == MqttConnectionState.disconnected);

  Stream<void> get _mqttConnected =>
      _connection$().where((it) => it == MqttConnectionState.connected);

  Stream<void> get _mqttReconnecting =>
      _connection$().where((it) => it == MqttConnectionState.disconnecting);

  void addHttpInterceptors(
    RequestOptions Function(RequestOptions, RequestInterceptorHandler)
        onRequest,
  ) {
    _dio.interceptors.add(InterceptorsWrapper(onRequest: onRequest));
  }

  Future<List<QParticipant>> addParticipants({
    required int roomId,
    required List<String> userIds,
  }) async {
    var t2 = addParticipantsImpl(roomId, userIds).run(_dio);

    return t2.map((it) => it.toList()).runOrThrow();
  }

  Future<QUser> blockUser({required String userId}) async {
    var t2 = blockUserImpl(userId).run(_dio);

    return t2.runOrThrow();
  }

  Future<QChatRoom> chatUser({
    required String userId,
    Json? extras,
  }) async {
    var t2 = chatUserImpl(userId, extras).run(_dio);

    return t2.runOrThrow();
  }

  Future<void> clearMessagesByChatRoomId({
    required List<String> roomUniqueIds,
  }) async {
    var t2 = clearMessagesImpl(roomUniqueIds).run(_dio);

    await t2.runOrThrow();
  }

  Future<void> clearUser() async {
    _storage.clear();
    _mqtt.disconnect();
  }

  Future<QChatRoom> createChannel({
    required String uniqueId,
    String? name,
    String? avatarUrl,
    Json? extras,
  }) async {
    var t2 = createChannelImpl(
      uniqueId,
      name: name,
      avatarUrl: avatarUrl,
      extras: extras,
    ).run(_dio);

    return t2.runOrThrow();
  }

  Future<QChatRoom> createGroupChat({
    required String name,
    required List<String> userIds,
    String? avatarUrl,
    Json? extras,
  }) async {
    var t2 = createGroupChatImpl(
      name,
      userIds,
      avatarUrl: avatarUrl,
      extras: extras,
    ).run(_dio);

    return t2.runOrThrow();
  }

  Future<List<QMessage>> deleteMessages({
    required List<String> messageUniqueIds,
  }) async {
    var t2 = deleteMessagesImpl(messageUniqueIds).run(_dio);

    return t2.map((it) => it.toList()).runOrThrow();
  }

  void enableDebugMode({
    required bool enable,
    QLogLevel level = QLogLevel.log,
  }) {
    _storage.debugEnabled = enable;
    _storage.logLevel = level;
  }

  Future<List<QChatRoom>> getAllChatRooms({
    bool? showParticipant,
    bool? showRemoved,
    bool? showEmpty,
    int? limit,
    int? page,
  }) async {
    var t2 = getAllChatRoomsImpl(
      showParticipant: showParticipant,
      showRemoved: showRemoved,
      showEmpty: showEmpty,
      limit: limit,
      page: page,
    ).run(_dio);

    return t2.map((it) => it.toList()).runOrThrow();
  }

  Future<List<QUser>> getBlockedUsers({
    int? page,
    int? limit,
  }) async {
    var t2 = getBlockedUsersImpl(page: page, limit: limit).run(_dio);

    return t2.map((it) => it.toList()).runOrThrow();
  }

  Future<QChatRoom> getChannel({
    required String uniqueId,
  }) async {
    var t2 = getChannelImpl(uniqueId).run(_dio);

    return t2.runOrThrow();
  }

  Future<List<QChatRoom>> getChatRooms({
    List<int>? roomIds,
    List<String>? uniqueIds,
    int? page,
    bool? showRemoved,
    bool? showParticipants,
  }) async {
    var t2 = getChatRoomsImpl(
      roomIds: roomIds,
      uniqueIds: uniqueIds,
      page: page,
      showRemoved: showRemoved,
      showParticipants: showParticipants,
    ).run(_dio);

    return t2.map((it) => it.toList()).runOrThrow();
  }

  Future<QChatRoomWithMessages> getChatRoomWithMessages({
    required int roomId,
  }) async {
    var t2 = getRoomWithMessagesImpl(roomId).map((v) {
      return v.map((v) => QChatRoomWithMessages(v.first, v.second.toList()));
    }).run(_dio);

    return t2.runOrThrow();
  }

  Future<String> getJWTNonce() async {
    return getNonceImpl().run(_dio).runOrThrow();
  }

  Future<List<QMessage>> getNextMessagesById({
    required int roomId,
    required int messageId,
    int? limit,
  }) async {
    var t2 = getNextMessagesImpl(roomId, messageId, limit: limit).run(_dio);

    return t2.map((it) => it.toList()).runOrThrow();
  }

  Future<List<QParticipant>> getParticipants({
    required String roomUniqueId,
    int? page,
    int? limit,
    String? sorting,
  }) async {
    var t2 = getParticipantsImpl(
      roomUniqueId,
      page: page,
      limit: limit,
      sorting: sorting,
    ).run(_dio);

    return t2.map((it) => it.toList()).runOrThrow();
  }

  Future<List<QMessage>> getPreviousMessagesById({
    required int roomId,
    required int messageId,
    int? limit,
  }) async {
    var t2 = getPreviousMessagesImpl(roomId, messageId, limit: limit).run(_dio);

    return t2.map((it) => it.toList()).runOrThrow();
  }

  String getBlurryThumbnailURL(String url) {
    var result = url.replaceAllMapped(
      _thumbnailURL,
      (match) => match.input //
          .replaceAll(
            match.group(1)!,
            r'/upload/w_320,h_320,c_limit,e_blur:30/',
          )
          .replaceAll(
            match.group(2)!,
            r'.png',
          ),
    );
    return result;
  }

  String getThumbnailURL(String url) {
    var result = url.replaceAllMapped(
      _thumbnailURL,
      (match) => match.input //
          .replaceAll(
            match.group(1)!,
            r'/upload/w_320,h_320,c_limit/',
          )
          .replaceAll(
            match.group(2)!,
            r'.png',
          ),
    );
    return result;
  }

  Future<int> getTotalUnreadCount() async {
    var t2 = getTotalUnreadImpl().run(_dio);

    return t2.runOrThrow();
  }

  Future<QAccount> getUserData() async {
    var t2 = getUserDataImpl().run(_dio);
    return t2.map((s) {
      var res = s.run(_storage);
      _storage = res.second;
      return res.first;
    }).runOrThrow();
  }

  Future<List<QUser>> getUsers({
    @deprecated String? searchUsername,
    int? page,
    int? limit,
  }) async {
    var t2 = getUsersImpl(
      query: searchUsername,
      page: page,
      limit: limit,
    ).run(_dio);

    return t2.map((it) => it.toList()).runOrThrow();
  }

  bool hasSetupUser() {
    return currentUser != null;
  }

  void Function() intercept({
    required QInterceptor interceptor,
    required Future<QMessage> Function(QMessage) callback,
  }) {
    return _interceptHook(interceptor, callback);
  }

  Future<void> markAsDelivered({
    required int roomId,
    required int messageId,
  }) async {
    var t2 = updateMessageStatusImpl(
      roomId,
      messageId,
      QMessageStatus.delivered,
    ).run(_dio);

    await t2.runOrThrow();
  }

  Future<void> markAsRead({
    required int roomId,
    required int messageId,
  }) async {
    var t2 = updateMessageStatusImpl(
      roomId,
      messageId,
      QMessageStatus.read,
    ).run(_dio);

    await t2.runOrThrow();
  }

  Stream<int> onChatRoomCleared() {
    return _roomCleared$;
  }

  Stream<void> onConnected() {
    return _mqttConnected;
  }

  Stream<void> onDisconnected() {
    return _mqttDisconnected;
  }

  Stream<QMessage> onMessageDeleted() {
    return _messageDeleted$;
  }

  Stream<QMessage> onMessageDelivered() {
    return _messageDelivered$;
  }

  Stream<QMessage> onMessageRead() {
    return _messageRead$;
  }

  Stream<QMessage> onMessageReceived() {
    return _messageReceived$;
  }

  Stream<QMessage> onMessageUpdated() {
    return _messageUpdated$;
  }

  Stream<void> onReconnecting() {
    return _mqttReconnecting;
  }

  Stream<QUserPresence> onUserOnlinePresence() {
    return _userPresence$;
  }

  Stream<QUserTyping> onUserTyping() {
    return _userTyping$;
  }

  Future<void> publishCustomEvent({
    required int roomId,
    required Json payload,
  }) async {
    var t2 = publishCustomEventImpl(roomId, payload).run(_mqtt);

    await t2.runOrThrow();
  }

  Future<void> publishOnlinePresence({
    required bool isOnline,
  }) async {
    await _connected();
    publishOnlinePresenceImpl(isOnline).run(_deps).runOrThrow();
  }

  Future<void> publishTyping({
    required int roomId,
    bool? isTyping = true,
  }) async {
    publishUserTypingImpl(roomId: roomId, isTyping: isTyping)
        .run(_deps)
        .runOrThrow();
  }

  Future<bool> registerDeviceToken({
    required String token,
    bool? isDevelopment,
  }) async {
    return registerDeviceTokenImpl(token, isDevelopment).run(_dio).runOrThrow();
  }

  Future<bool> removeDeviceToken({
    required String token,
    bool? isDevelopment,
  }) {
    return unregisterDeviceTokenImpl(token, isDevelopment)
        .run(_dio)
        .runOrThrow();
  }

  Future<List<String>> removeParticipants({
    required int roomId,
    required List<String> userIds,
  }) async {
    return removeParticipantImpl(roomId: roomId, userIds: userIds)
        .run(_dio)
        .map((it) => it.toList())
        .runOrThrow();
  }

  StreamTransformer<QUploadProgress<String>, QUploadProgress<QMessage>>
      _sendFileMessageTransformer$(File file, QMessage message) {
    return StreamTransformer.fromHandlers(handleData: (item, sink) async {
      if (item.data != null) {
        message.payload ??= <String, dynamic>{};
        message.payload!['url'] = item.data;
        message.payload!['size'] = file.lengthSync();
        message.text = '[file] ${item.data} [/file]';

        var m = await sendMessage(message: message);
        sink.add(QUploadProgress(progress: 100, data: m));
      } else {
        sink.add(QUploadProgress(progress: item.progress));
      }
    });
  }

  Stream<QUploadProgress<QMessage>> sendFileMessage({
    required QMessage message,
    required File file,
  }) {
    var stream = upload(file);
    var resp = stream.transform(_sendFileMessageTransformer$(file, message));
    return resp;
  }

  Future<QMessage> sendMessage({
    required QMessage message,
  }) async {
    var t2 = tryCatch(
      () => _triggerHook(QInterceptor.messageBeforeSent, message),
    );
    var t3 = t2.flatMap((message) => sendMessageImpl(message).run(_dio));
    return t3.map((state) {
      var res = state.run(_storage.messages);
      _storage.messages = res.second.toSet();
      return res.first;
    }).runOrThrow();
  }

  void setCustomHeader(Map<String, String> headers) {
    _storage.customHeaders = headers;
  }

  /// Set [period] (in milliseconds) in which sync and sync_event run
  void setSyncInterval(double period) {
    _storage.syncInterval = period.ceil().milliseconds;
  }

  Future<void> setup(String appId) {
    return setupWithCustomServer(appId);
  }

  Future<void> setupWithCustomServer(
    String appId, {
    String baseUrl = defaultBaseUrl,
    String brokerUrl = defaultBrokerUrl,
    String brokerLbUrl = defaultBrokerLbUrl,
    int syncInterval = defaultSyncInterval,
    int syncIntervalWhenConnected = defaultSyncIntervalWhenConnected,
  }) async {
    _storage.appId = appId;
    _storage.baseUrl = baseUrl;
    _storage.brokerUrl = brokerUrl;
    _storage.brokerLbUrl = brokerLbUrl;
    _storage.syncInterval = syncInterval.milliseconds;
    _storage.syncIntervalWhenConnected = syncIntervalWhenConnected.milliseconds;

    try {
      await appConfigUseCase
          .run(_dio)
          .map((s) => s.run(_storage))
          .map((it) => _storage = it.second)
          .runOrThrow();
    } catch (_) {}
  }

  Future<QAccount> setUser({
    required String userId,
    required String userKey,
    String? username,
    String? avatarUrl,
    Json? extras,
  }) async {
    if (userId.isEmpty) {
      throw ArgumentError.value(
        userId,
        'userId',
        'userId should not be empty string',
      );
    }
    if (userKey.isEmpty) {
      throw ArgumentError.value(
        userKey,
        'userKey',
        'userKey should not be empty string',
      );
    }

    return setUserImpl(
      userId: userId,
      userKey: userKey,
      displayName: username,
      avatarUrl: avatarUrl,
      extras: extras,
    )
        .run(_dio)
        .map((state) {
          var data = state.run(_storage);

          _storage = data.second;
          return data.first;
        })
        .runOrThrow()
        .tap((_) => _connectMqtt());
  }

  Future<QAccount> setUserWithIdentityToken({required String token}) {
    return setUserWithIdentityTokenImpl(token)
        .run(_dio)
        .map((state) {
          var data = state.run(_storage);
          _storage = data.second;
          return data.first;
        })
        .runOrThrow()
        .tap((_) => _connectMqtt());
  }

  Stream<MqttConnectionState> _connectionState() async* {
    const duration = Duration(milliseconds: 100);
    var stream = Stream.periodic(duration, (_) => _mqtt.connectionStatus?.state)
        .where((v) => v != null)
        .cast<MqttConnectionState>()
        .distinct();

    yield* stream;
  }

  Future<void> _connected() async {
    var stream = _connectionState();

    await stream.firstWhere((v) => v == MqttConnectionState.connected);
  }

  Future<void> _connectMqtt() async {
    if (_storage.isRealtimeEnabled) {
      await _mqtt.connect();
      await _connected();
    }

    var token = _storage.token!;
    var r1 = mqttSubscribeTopic(TopicBuilder.messageNew(token));
    var r2 = mqttSubscribeTopic(TopicBuilder.messageUpdated(token));
    var r3 = mqttSubscribeTopic(TopicBuilder.notification(token));
    r1.run(_mqtt).runOrThrow();
    r2.run(_mqtt).runOrThrow();
    r3.run(_mqtt).runOrThrow();
  }

  Debug get debug => Debug(
        mqtt: _mqtt,
        interval: _interval$(),
      );

  void subscribeChatRoom(QChatRoom room) async {
    await _connected();

    var roomId = room.id.toString();
    // var state = _mqtt.connectionStatus?.state.toString();
    var subs1 = mqttSubscribeTopic(TopicBuilder.messageRead(roomId)).run(_mqtt);
    var subs2 =
        mqttSubscribeTopic(TopicBuilder.messageDelivered(roomId)).run(_mqtt);
    var subs3 = mqttSubscribeTopic(TopicBuilder.typing(roomId, '+')).run(_mqtt);

    subs1.runOrThrow();
    subs2.runOrThrow();
    subs3.runOrThrow();
  }

  void unsubscribeChatRoom(QChatRoom room) {
    var roomId = room.id.toString();
    mqttUnsubscribeTopic(TopicBuilder.messageRead(roomId))
        .call(mqttUnsubscribeTopic(TopicBuilder.messageDelivered(roomId))
            .call(mqttUnsubscribeTopic(TopicBuilder.typing(roomId, '+'))))
        .run(_mqtt)
        .run();
  }

  Stream<Json> subscribeCustomEvent({
    required int roomId,
  }) async* {
    var topic = TopicBuilder.customEvent(roomId);
    var stream =
        mqttSubscribeTopic(topic).call(mqttForTopic(topic)).run(_mqtt).run();

    await for (var data in stream) {
      yield jsonDecode(data.payload) as Json;
    }
  }

  void unsubscribeCustomEvent({required int roomId}) {
    var topic = TopicBuilder.customEvent(roomId);
    mqttUnsubscribeTopic(topic).run(_mqtt).run();
  }

  void subscribeUserOnlinePresence(String userId) {
    mqttSubscribeTopic(TopicBuilder.presence(userId)).run(_mqtt).runOrThrow();
  }

  void unsubscribeUserOnlinePresence(String userId) {
    mqttUnsubscribeTopic(TopicBuilder.presence(userId)).run(_mqtt).run();
  }

  void synchronize({String? lastMessageId}) async {
    await synchronizeImpl(lastMessageId).run(_dio).map((r) {
      _storage.lastMessageId = r.first;
      r.second.forEach((m) => _messageReceivedSubs$.sink.add(m));
      return r;
    }).run();
  }

  void synchronizeEvent({String? lastEventId}) async {
    await synchronizeEventImpl(int.tryParse(lastEventId ?? '')).run(_dio).run();
  }

  Future<QUser> unblockUser({required String userId}) {
    return unblockUserImpl(userId).run(_dio).runOrThrow();
  }

  Future<QChatRoom> updateChatRoom({
    required int roomId,
    String? name,
    String? avatarUrl,
    Json? extras,
  }) {
    return updateChatRoomImpl(
      roomId: roomId,
      name: name,
      avatarUrl: avatarUrl,
      extras: extras,
    ).run(_dio).map((state) {
      var data = state.run(_storage.rooms);
      _storage.rooms = data.second.toSet();
      return data.first;
    }).runOrThrow();
  }

  Future<QAccount> updateUser({
    String? name,
    String? avatarUrl,
    Json? extras,
  }) {
    return updateUserImpl(name: name, avatarUrl: avatarUrl, extras: extras)
        .run(_dio)
        .map((state) {
      var data = state.run(_storage);
      _storage = data.second;
      return data.first;
    }).runOrThrow();
  }

  Future<QMessage> updateMessage({required QMessage message}) {
    return updateMessageImpl(message).run(_dio).map((state) {
      var data = state.run(_storage.messages);
      _storage.messages = data.second.toSet();
      return data.first;
    }).runOrThrow();
  }

  Stream<QUploadProgress<String>> upload(
    File file, {
    CancelToken? cancelToken,
  }) async* {
    var controller = StreamController<QUploadProgress<String>>();
    var uploadUrl = _storage.uploadUrl;
    var filename = file.path.split('/').last;
    var formData = FormData.fromMap(<String, dynamic>{
      'file': await MultipartFile.fromFile(file.path, filename: filename),
    });

    // ignore: unawaited_futures
    _dio
        .post<Json>(
          uploadUrl,
          data: formData,
          onSendProgress: (count, total) {
            var percentage = (count / total) * 100;
            controller.add(QUploadProgress(progress: percentage));
          },
          cancelToken: cancelToken,
        )
        .then((resp) => resp.data)
        .then((json) {
          return (json!['results'] as Map)['file']['url'] as String;
        })
        .then(
          (url) => controller.add(QUploadProgress(progress: 100, data: url)),
        )
        .catchError(
          (Object err, StackTrace trace) => controller.addError(err, trace),
        );

    yield* controller.stream;
  }

  Future<List<QMessage>> getFileList({
    List<int>? roomIds,
    String? fileType,
    List<String>? includeExtensions,
    List<String>? excludeExtensions,
    String? userId,
    int? page,
    int? limit,
  }) async {
    return getFileListImpl(
      roomIds: roomIds,
      fileType: fileType,
      includeExtensions: includeExtensions,
      excludeExtensions: excludeExtensions,
      userId: userId,
      page: page,
      limit: limit,
    ).run(_dio).map((it) => it.toList()).runOrThrow();
  }

  Future<bool> closeRealtimeConnection() async {
    if (isLogin) {
      storage.isRealtimeManuallyClosed = true;
      tryCatch(() async {
        _mqtt.disconnect();
        return true;
      }).runOrThrow().ignore();
      return true;
    }
    return false;
  }

  Future<bool> openRealtimeConnection() async {
    if (isLogin && storage.isRealtimeEnabled) {
      storage.isRealtimeManuallyClosed = false;
      tryCatch(() async {
        await _mqtt.connect();
        return true;
      }).runOrThrow().ignore();
      return true;
    }
    return false;
  }

  String _generateUniqueId() =>
      'flutter-${DateTime.now().millisecondsSinceEpoch}';

  QMessage generateMessage({
    required int chatRoomId,
    required String text,
    Json? extras,
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
      sender: currentUser!,
      status: QMessageStatus.sending,
      type: QMessageType.text,
    );
  }

  QMessage generateCustomMessage({
    required int chatRoomId,
    required String text,
    required String type,
    Json? extras,
    required Json payload,
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
      sender: currentUser!,
      status: QMessageStatus.sending,
      type: QMessageType.custom,
    );
  }

  QMessage generateFileAttachmentMessage({
    required int chatRoomId,
    required String caption,
    required String url,
    String? filename,
    String text = 'File attachment',
    int? size,
    Json? extras,
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
      sender: currentUser!,
      status: QMessageStatus.sending,
      type: QMessageType.attachment,
    );
  }

  // --- Hooks
  final Set<QHook> _hooks = {};

  void Function() _interceptHook<T extends Object>(
      QInterceptor hook, Future<T> Function(T) fn) {
    var _hook = QHook(hook, fn);
    _hooks.add(_hook);
    return () => _hooks.remove(_hook);
  }

  Future<T> _triggerHook<T>(QInterceptor hook, T payload) async {
    var fns = _hooks.where((it) => it.hook == hook).map((it) => it.callback);
    var res = fns.fold(
      Future.value(payload),
      (result, fn) => Future.sync(() => fn(result) as Future<T>),
    );

    return res;
  }

  static Future<QiscusSDK> withAppId(String appId) async {
    var sdk = QiscusSDK();
    await sdk.setup(appId);
    return sdk;
  }

  static Future<QiscusSDK> withCustomServer(
    String appId, {
    String baseUrl = defaultBaseUrl,
    String brokerUrl = defaultBrokerUrl,
    String brokerLbUrl = defaultBrokerLbUrl,
    int syncInterval = defaultSyncInterval,
    int syncIntervalWhenConnected = defaultSyncIntervalWhenConnected,
  }) async {
    var sdk = QiscusSDK();
    await sdk.setupWithCustomServer(
      appId,
      baseUrl: baseUrl,
      brokerUrl: brokerUrl,
      brokerLbUrl: brokerLbUrl,
      syncInterval: syncInterval,
      syncIntervalWhenConnected: syncIntervalWhenConnected,
    );
    return sdk;
  }
}

extension _TaskExt<T> on Task<T> {
  Future<void> runIgnored() async {
    run().ignore();
  }
}

extension _TaskEither<L extends String, R> on TaskEither<L, R> {
  Future<R> runOrThrow() async {
    return run().then((it) => it.toThrow());
  }
}

extension _IOEither<L extends String, R> on IOEither<L, R> {
  R runOrThrow() {
    return run().toThrow();
  }
}

extension _EitherX<L extends String, R> on Either<L, R> {
  R toThrow() {
    return match(
      (l) => throw l,
      (r) => r,
    );
  }
}

TaskEither<String, T> fromTask<T>(Task<T> task) {
  return TaskEither.fromTask(task);
}
