import 'dart:io';

import 'package:dio/dio.dart';

import '../core.dart';
import '../providers/http-client-provider.dart';
import 'commons.dart';
import 'message/message-model.dart';
import 'room/room-model.dart';
import 'user/user-model.dart';

abstract class IQiscusSDK {
  String? get appId;
  QAccount? get currentUser;
  String? get token;
  bool get isLogin;
  Storage get storage;

  void addHttpInterceptors(RequestInterceptorFn onRequest);

  Future<List<QParticipant>> addParticipants({
    required int roomId,
    required List<String> userIds,
  });

  Future<QUser> blockUser({required String userId});

  Future<QChatRoom> chatUser({
    required String userId,
    Map<String, Object?>? extras,
  });

  Future<void> clearMessagesByChatRoomId({
    required List<String> roomUniqueIds,
  });

  Future<void> clearUser();

  Future<QChatRoom> createChannel({
    required String uniqueId,
    String? name,
    String? avatarUrl,
    Map<String, Object?>? extras,
  });

  Future<QChatRoom> createGroupChat({
    required String name,
    required List<String> userIds,
    String? avatarUrl,
    Map<String, Object?>? extras,
  });

  Future<List<QMessage>> deleteMessages({
    required List<String> messageUniqueIds,
  });

  void enableDebugMode({
    required bool enable,
    QLogLevel level = QLogLevel.log,
  });

  Future<List<QChatRoom>> getAllChatRooms({
    bool? showParticipant,
    bool? showRemoved,
    bool? showEmpty,
    int? limit,
    int? page,
  });

  Future<List<QUser>> getBlockedUsers({
    int? page,
    int? limit,
  });

  Future<QChatRoom> getChannel({
    required String uniqueId,
  });

  Future<List<QChatRoom>> getChatRooms({
    List<int>? roomIds,
    List<String>? uniqueIds,
    int? page,
    bool? showRemoved,
    bool? showParticipants,
  });

  Future<QChatRoomWithMessages> getChatRoomWithMessages({
    required int roomId,
  });

  Future<String> getJWTNonce();

  Future<List<QMessage>> getNextMessagesById({
    required int roomId,
    required int messageId,
    int? limit,
  });

  Future<List<QParticipant>> getParticipants({
    required String roomUniqueId,
    int? page,
    int? limit,
    String? sorting,
  });

  Future<List<QMessage>> getPreviousMessagesById({
    required int roomId,
    required int messageId,
    int? limit,
  });

  String getBlurryThumbnailURL(String url);

  String getThumbnailURL(String url);

  Future<int> getTotalUnreadCount();

  Future<List<QUser>> getUsers({
    @deprecated String? searchUsername,
    int? page,
    int? limit,
  });

  bool hasSetupUser();

  void Function() intercept({
    required QInterceptor interceptor,
    required Future<QMessage> Function(QMessage) callback,
  });

  Future<void> markAsDelivered({
    required int roomId,
    required int messageId,
  });
  Future<void> markAsRead({
    required int roomId,
    required int messageId,
  });

  Stream<int> onChatRoomCleared();

  Stream<void> onConnected();

  Stream<void> onDisconnected();

  Stream<QMessage> onMessageDeleted();

  Stream<QMessage> onMessageDelivered();

  Stream<QMessage> onMessageRead();

  Stream<QMessage> onMessageReceived();

  Stream<QMessage> onMessageUpdated();

  Stream<void> onReconnecting();

  Stream<QUserPresence> onUserOnlinePresence();

  Stream<QUserTyping> onUserTyping();

  Future<void> publishCustomEvent({
    required int roomId,
    required Map<String, Object?> payload,
  });

  Future<void> publishOnlinePresence({
    required bool isOnline,
  });

  Future<void> publishTyping({
    required int roomId,
    bool? isTyping = true,
  });

  Future<bool> registerDeviceToken({
    required String token,
    bool? isDevelopment,
  });

  Future<bool> removeDeviceToken({
    required String token,
    bool? isDevelopment,
  });

  Future<List<String>> removeParticipants({
    required int roomId,
    required List<String> userIds,
  });

  Stream<QUploadProgress<QMessage>> sendFileMessage({
    required QMessage message,
    required File file,
  });

  Future<QMessage> sendMessage({
    required QMessage message,
  });

  void setCustomHeader(Map<String, String> headers);

  /// Set [period] (in milliseconds) in which sync and sync_event run
  void setSyncInterval(double period);

  Future<void> setup(String appId);

  Future<void> setupWithCustomServer(
    String appId, {
    String baseUrl = defaultBaseUrl,
    String brokerUrl = defaultBrokerUrl,
    String brokerLbUrl = defaultBrokerLbUrl,
    int syncInterval = defaultSyncInterval,
    int syncIntervalWhenConnected = defaultSyncIntervalWhenConnected,
  });

  Future<QAccount> setUser({
    required String userId,
    required String userKey,
    String? username,
    String? avatarUrl,
    Map<String, Object?>? extras,
  });

  Future<QAccount> setUserWithIdentityToken({required String token});

  void subscribeChatRoom(QChatRoom room);

  void unsubscribeChatRoom(QChatRoom room);

  Stream<Map<String, Object?>> subscribeCustomEvent({
    required int roomId,
  });

  void unsubscribeCustomEvent({required int roomId});

  void subscribeUserOnlinePresence(String userId);

  void unsubscribeUserOnlinePresence(String userId);

  void synchronize({String? lastMessageId});

  void synchronizeEvent({String? lastEventId});

  Future<QUser> unblockUser({required String userId});
  Future<QChatRoom> updateChatRoom({
    required int roomId,
    String? name,
    String? avatarUrl,
    Map<String, Object?>? extras,
  });

  Future<QAccount> updateUser({
    String? name,
    String? avatarUrl,
    Map<String, Object?>? extras,
  });

  Future<QMessage> updateMessage({required QMessage message});

  Stream<QUploadProgress<String>> upload(File file);

  Future<List<QMessage>> getFileList({
    List<int>? roomIds,
    String? fileType,
    List<String>? includeExtensions,
    List<String>? excludeExtensions,
    String? userId,
    int? page,
    int? limit,
  });

  Future<bool> closeRealtimeConnection();
  Future<bool> openRealtimeConnection();
  QMessage generateMessage({
    required int chatRoomId,
    required String text,
    Map<String, Object?>? extras,
  });

  QMessage generateCustomMessage({
    required int chatRoomId,
    required String text,
    required String type,
    Map<String, Object?>? extras,
    required Map<String, Object?> payload,
  });

  QMessage generateFileAttachmentMessage({
    required int chatRoomId,
    required String caption,
    required String url,
    String? filename,
    String text = 'File attachment',
    int? size,
    Map<String, Object?>? extras,
  });
}
