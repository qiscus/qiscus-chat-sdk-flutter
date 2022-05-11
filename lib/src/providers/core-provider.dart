import 'package:qiscus_chat_sdk/src/domain/user/user-model.dart';
import 'package:qiscus_chat_sdk/src/domain/room/room-model.dart';
import 'package:qiscus_chat_sdk/src/domain/message/message-model.dart';
import 'package:qiscus_chat_sdk/src/domain/commons.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'dart:io';

import 'package:riverpod/riverpod.dart';

import '../domain/qiscus.dart';
import 'http-client-provider.dart';

final coreProvider = Provider((ref) {
  return Core(ref);
});

class Core extends IQiscusSDK {
  Core(this.ref);
  final Ref ref;

  @override
  void addHttpInterceptors(RequestInterceptorFn onRequest) {
    ref.read(httpInterceptorsProvider.notifier).update((state) {
      return [...state, onRequest];
    });
  }

  @override
  Future<List<QParticipant>> addParticipants({
    required int roomId,
    required List<String> userIds,
  }) {
    // TODO: implement addParticipants
    throw UnimplementedError();
  }

  @override
  // TODO: implement appId
  String? get appId => throw UnimplementedError();

  @override
  Future<QUser> blockUser({required String userId}) {
    // TODO: implement blockUser
    throw UnimplementedError();
  }

  @override
  Future<QChatRoom> chatUser({
    required String userId,
    Map<String, Object>? extras,
  }) {
    // TODO: implement chatUser
    throw UnimplementedError();
  }

  @override
  Future<void> clearMessagesByChatRoomId({
    required List<String> roomUniqueIds,
  }) {
    // TODO: implement clearMessagesByChatRoomId
    throw UnimplementedError();
  }

  @override
  Future<void> clearUser() {
    // TODO: implement clearUser
    throw UnimplementedError();
  }

  @override
  Future<bool> closeRealtimeConnection() {
    // TODO: implement closeRealtimeConnection
    throw UnimplementedError();
  }

  @override
  Future<QChatRoom> createChannel({
    required String uniqueId,
    String? name,
    String? avatarUrl,
    Map<String, dynamic>? extras,
  }) {
    // TODO: implement createChannel
    throw UnimplementedError();
  }

  @override
  Future<QChatRoom> createGroupChat({
    required String name,
    required List<String> userIds,
    String? avatarUrl,
    Map<String, dynamic>? extras,
  }) {
    // TODO: implement createGroupChat
    throw UnimplementedError();
  }

  @override
  // TODO: implement currentUser
  QAccount? get currentUser => throw UnimplementedError();

  @override
  Future<List<QMessage>> deleteMessages({
    required List<String> messageUniqueIds,
  }) {
    // TODO: implement deleteMessages
    throw UnimplementedError();
  }

  @override
  void enableDebugMode({
    required bool enable,
    QLogLevel level = QLogLevel.log,
  }) {
    // TODO: implement enableDebugMode
  }

  @override
  QMessage generateCustomMessage({
    required int chatRoomId,
    required String text,
    required String type,
    Map<String, dynamic>? extras,
    required Map<String, dynamic> payload,
  }) {
    // TODO: implement generateCustomMessage
    throw UnimplementedError();
  }

  @override
  QMessage generateFileAttachmentMessage({
    required int chatRoomId,
    required String caption,
    required String url,
    String? filename,
    String text = 'File attachment',
    int? size,
    Map<String, dynamic>? extras,
  }) {
    // TODO: implement generateFileAttachmentMessage
    throw UnimplementedError();
  }

  @override
  QMessage generateMessage({
    required int chatRoomId,
    required String text,
    Map<String, dynamic>? extras,
  }) {
    // TODO: implement generateMessage
    throw UnimplementedError();
  }

  @override
  Future<List<QChatRoom>> getAllChatRooms({
    bool? showParticipant,
    bool? showRemoved,
    bool? showEmpty,
    int? limit,
    int? page,
  }) {
    // TODO: implement getAllChatRooms
    throw UnimplementedError();
  }

  @override
  Future<List<QUser>> getBlockedUsers({int? page, int? limit}) {
    // TODO: implement getBlockedUsers
    throw UnimplementedError();
  }

  @override
  String getBlurryThumbnailURL(String url) {
    // TODO: implement getBlurryThumbnailURL
    throw UnimplementedError();
  }

  @override
  Future<QChatRoom> getChannel({required String uniqueId}) {
    // TODO: implement getChannel
    throw UnimplementedError();
  }

  @override
  Future<QChatRoomWithMessages> getChatRoomWithMessages({required int roomId}) {
    // TODO: implement getChatRoomWithMessages
    throw UnimplementedError();
  }

  @override
  Future<List<QChatRoom>> getChatRooms({
    List<int>? roomIds,
    List<String>? uniqueIds,
    int? page,
    bool? showRemoved,
    bool? showParticipants,
  }) {
    // TODO: implement getChatRooms
    throw UnimplementedError();
  }

  @override
  Future<List<QMessage>> getFileList({
    List<int>? roomIds,
    String? fileType,
    List<String>? includeExtensions,
    List<String>? excludeExtensions,
    String? userId,
    int? page,
    int? limit,
  }) {
    // TODO: implement getFileList
    throw UnimplementedError();
  }

  @override
  Future<String> getJWTNonce() {
    // TODO: implement getJWTNonce
    throw UnimplementedError();
  }

  @override
  Future<List<QMessage>> getNextMessagesById(
      {required int roomId, required int messageId, int? limit}) {
    // TODO: implement getNextMessagesById
    throw UnimplementedError();
  }

  @override
  Future<List<QParticipant>> getParticipants({
    required String roomUniqueId,
    int? page,
    int? limit,
    String? sorting,
  }) {
    // TODO: implement getParticipants
    throw UnimplementedError();
  }

  @override
  Future<List<QMessage>> getPreviousMessagesById({
    required int roomId,
    required int messageId,
    int? limit,
  }) {
    // TODO: implement getPreviousMessagesById
    throw UnimplementedError();
  }

  @override
  String getThumbnailURL(String url) {
    // TODO: implement getThumbnailURL
    throw UnimplementedError();
  }

  @override
  Future<int> getTotalUnreadCount() {
    // TODO: implement getTotalUnreadCount
    throw UnimplementedError();
  }

  @override
  Future<List<QUser>> getUsers({
    String? searchUsername,
    int? page,
    int? limit,
  }) {
    // TODO: implement getUsers
    throw UnimplementedError();
  }

  @override
  bool hasSetupUser() {
    // TODO: implement hasSetupUser
    throw UnimplementedError();
  }

  @override
  void Function() intercept({
    required QInterceptor interceptor,
    required Future<QMessage> Function(QMessage p1) callback,
  }) {
    // TODO: implement intercept
    throw UnimplementedError();
  }

  @override
  // TODO: implement isLogin
  bool get isLogin => throw UnimplementedError();

  @override
  Future<void> markAsDelivered({required int roomId, required int messageId}) {
    // TODO: implement markAsDelivered
    throw UnimplementedError();
  }

  @override
  Future<void> markAsRead({required int roomId, required int messageId}) {
    // TODO: implement markAsRead
    throw UnimplementedError();
  }

  @override
  Stream<int> onChatRoomCleared() {
    // TODO: implement onChatRoomCleared
    throw UnimplementedError();
  }

  @override
  Stream<void> onConnected() {
    // TODO: implement onConnected
    throw UnimplementedError();
  }

  @override
  Stream<void> onDisconnected() {
    // TODO: implement onDisconnected
    throw UnimplementedError();
  }

  @override
  Stream<QMessage> onMessageDeleted() {
    // TODO: implement onMessageDeleted
    throw UnimplementedError();
  }

  @override
  Stream<QMessage> onMessageDelivered() {
    // TODO: implement onMessageDelivered
    throw UnimplementedError();
  }

  @override
  Stream<QMessage> onMessageRead() {
    // TODO: implement onMessageRead
    throw UnimplementedError();
  }

  @override
  Stream<QMessage> onMessageReceived() {
    // TODO: implement onMessageReceived
    throw UnimplementedError();
  }

  @override
  Stream<QMessage> onMessageUpdated() {
    // TODO: implement onMessageUpdated
    throw UnimplementedError();
  }

  @override
  Stream<void> onReconnecting() {
    // TODO: implement onReconnecting
    throw UnimplementedError();
  }

  @override
  Stream<QUserPresence> onUserOnlinePresence() {
    // TODO: implement onUserOnlinePresence
    throw UnimplementedError();
  }

  @override
  Stream<QUserTyping> onUserTyping() {
    // TODO: implement onUserTyping
    throw UnimplementedError();
  }

  @override
  Future<bool> openRealtimeConnection() {
    // TODO: implement openRealtimeConnection
    throw UnimplementedError();
  }

  @override
  Future<void> publishCustomEvent(
      {required int roomId, required Map<String, dynamic> payload}) {
    // TODO: implement publishCustomEvent
    throw UnimplementedError();
  }

  @override
  Future<void> publishOnlinePresence({required bool isOnline}) {
    // TODO: implement publishOnlinePresence
    throw UnimplementedError();
  }

  @override
  Future<void> publishTyping({required int roomId, bool? isTyping = true}) {
    // TODO: implement publishTyping
    throw UnimplementedError();
  }

  @override
  Future<bool> registerDeviceToken(
      {required String token, bool? isDevelopment}) {
    // TODO: implement registerDeviceToken
    throw UnimplementedError();
  }

  @override
  Future<bool> removeDeviceToken({required String token, bool? isDevelopment}) {
    // TODO: implement removeDeviceToken
    throw UnimplementedError();
  }

  @override
  Future<List<String>> removeParticipants({
    required int roomId,
    required List<String> userIds,
  }) {
    // TODO: implement removeParticipants
    throw UnimplementedError();
  }

  @override
  Stream<QUploadProgress<QMessage>> sendFileMessage({
    required QMessage message,
    required File file,
  }) {
    // TODO: implement sendFileMessage
    throw UnimplementedError();
  }

  @override
  Future<QMessage> sendMessage({required QMessage message}) {
    // TODO: implement sendMessage
    throw UnimplementedError();
  }

  @override
  void setCustomHeader(Map<String, String> headers) {
    // TODO: implement setCustomHeader
  }

  @override
  void setSyncInterval(double period) {
    // TODO: implement setSyncInterval
  }

  @override
  Future<QAccount> setUser({
    required String userId,
    required String userKey,
    String? username,
    String? avatarUrl,
    Map<String, dynamic>? extras,
  }) {
    // TODO: implement setUser
    throw UnimplementedError();
  }

  @override
  Future<QAccount> setUserWithIdentityToken({required String token}) {
    // TODO: implement setUserWithIdentityToken
    throw UnimplementedError();
  }

  @override
  Future<void> setup(String appId) {
    // TODO: implement setup
    throw UnimplementedError();
  }

  @override
  Future<void> setupWithCustomServer(
    String appId, {
    String baseUrl = defaultBaseUrl,
    String brokerUrl = defaultBrokerUrl,
    String brokerLbUrl = defaultBrokerLbUrl,
    int syncInterval = defaultSyncInterval,
    int syncIntervalWhenConnected = defaultSyncIntervalWhenConnected,
  }) {
    // TODO: implement setupWithCustomServer
    throw UnimplementedError();
  }

  @override
  // TODO: implement storage
  Storage get storage => throw UnimplementedError();

  @override
  void subscribeChatRoom(QChatRoom room) {
    // TODO: implement subscribeChatRoom
  }

  @override
  Stream<Map<String, dynamic>> subscribeCustomEvent({required int roomId}) {
    // TODO: implement subscribeCustomEvent
    throw UnimplementedError();
  }

  @override
  void subscribeUserOnlinePresence(String userId) {
    // TODO: implement subscribeUserOnlinePresence
  }

  @override
  void synchronize({String? lastMessageId}) {
    // TODO: implement synchronize
  }

  @override
  void synchronizeEvent({String? lastEventId}) {
    // TODO: implement synchronizeEvent
  }

  @override
  // TODO: implement token
  String? get token => throw UnimplementedError();

  @override
  Future<QUser> unblockUser({required String userId}) {
    // TODO: implement unblockUser
    throw UnimplementedError();
  }

  @override
  void unsubscribeChatRoom(QChatRoom room) {
    // TODO: implement unsubscribeChatRoom
  }

  @override
  void unsubscribeCustomEvent({required int roomId}) {
    // TODO: implement unsubscribeCustomEvent
  }

  @override
  void unsubscribeUserOnlinePresence(String userId) {
    // TODO: implement unsubscribeUserOnlinePresence
  }

  @override
  Future<QChatRoom> updateChatRoom({
    required int roomId,
    String? name,
    String? avatarUrl,
    Map<String, dynamic>? extras,
  }) {
    // TODO: implement updateChatRoom
    throw UnimplementedError();
  }

  @override
  Future<QMessage> updateMessage({required QMessage message}) {
    // TODO: implement updateMessage
    throw UnimplementedError();
  }

  @override
  Future<QAccount> updateUser(
      {String? name, String? avatarUrl, Map<String, dynamic>? extras}) {
    // TODO: implement updateUser
    throw UnimplementedError();
  }

  @override
  Stream<QUploadProgress<String>> upload(File file) {
    // TODO: implement upload
    throw UnimplementedError();
  }
}
