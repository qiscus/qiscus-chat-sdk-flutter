import 'dart:io' if (dart.library.js) 'dart:html';

import 'package:meta/meta.dart';

import 'core/logger.dart';
import 'features/message/message.dart';
import 'features/room/room.dart';
import 'features/user/user.dart';
import 'typedefs.dart';

abstract class IQiscusSDK {
  String get appId;

  QAccount get currentUser;

  /// You can check whether a user is authenticated or not,
  /// and make sure that the user is allowed to use Qiscus Chat SDK features.
  /// When the [callback] is true, it means that user already authenticated,
  /// otherwise false means user is not authenticated yet.
  bool hasSetupUser({@required void Function(bool) callback});

  void addParticipant({
    @required int roomId,
    @required List<String> userIds,
    @required Callback1<List<QParticipant>> callback,
  });

  void blockUser({
    @required String userId,
    @required Callback1<QUser> callback,
  });

  void chatUser({
    @required String userId,
    Map<String, dynamic> extras,
    @required Callback1<QChatRoom> callback,
  });

  void clearMessagesByChatRoomId({
    @required List<String> roomUniqueIds,
    @required Callback0 callback,
  });

  void clearUser({
    @required Callback0 callback,
  });

  void createChannel({
    @required String uniqueId,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
    @required Callback1<QChatRoom> callback,
  });

  void createGroupChat({
    @required String name,
    @required List<String> userIds,
    String avatarUrl,
    Map<String, dynamic> extras,
    @required Callback1<QChatRoom> callback,
  });

  void deleteMessages({
    @required List<String> messageUniqueIds,
    @required Callback1<List<QMessage>> callback,
  });

  void enableDebugMode({
    @required bool enable,
    QLogLevel level = QLogLevel.log,
  });

  void getAllChatRooms({
    bool showParticipant,
    bool showRemoved,
    bool showEmpty,
    int limit,
    int page,
    @required Callback1<List<QChatRoom>> callback,
  });

  void getBlockedUsers({
    int page,
    int limit,
    @required Callback1<List<QUser>> callback,
  });

  void getChannel({
    @required String uniqueId,
    @required Callback1<QChatRoom> callback,
  });

  void getChatRooms({
    List<int> roomIds,
    List<String> uniqueIds,
    int page,
    bool showRemoved,
    bool showParticipants,
    @required Callback1<List<QChatRoom>> callback,
  });

  void getChatRoomWithMessages({
    @required int roomId,
    @required Callback2<QChatRoom, List<QMessage>> callback,
  });

  void getJWTNonce({
    @required Callback1<String> callback,
  });

  void getNextMessagesById({
    @required int roomId,
    @required int messageId,
    int limit,
    @required Callback1<List<QMessage>> callback,
  });

  void getParticipants({
    @required String roomUniqueId,
    int page,
    int limit,
    String sorting,
    @required Callback1<List<QParticipant>> callback,
  });

  void getPreviousMessagesById({
    @required int roomId,
    int limit,
    int messageId,
    @required Callback1<List<QMessage>> callback,
  });

  String getThumbnailURL(String url) => url;

  void getTotalUnreadCount({
    @required Callback1<int> callback,
  });

  void getUserData({
    @required Callback1<QAccount> callback,
  });

  void getUsers({
    @Deprecated('You can not search user anymore, but this params will remain')
        String searchUsername,
    int page,
    int limit,
    @required Callback1<List<QUser>> callback,
  });

  void intercept({
    @required String interceptor,
    @required Future<QMessage> Function(QMessage) callback,
  });

  void markAsDelivered({
    @required int roomId,
    @required int messageId,
    @required Callback0 callback,
  });

  void markAsRead({
    @required int roomId,
    @required int messageId,
    @required Callback0 callback,
  });

  void publishCustomEvent({
    @required int roomId,
    @required Map<String, dynamic> payload,
    @required Callback0 callback,
  });

  void publishOnlinePresence({
    @required bool isOnline,
    @required Callback0 callback,
  });

  void publishTyping({
    @required int roomId,
    bool isTyping = true,
  });

  void registerDeviceToken({
    @required String token,
    bool isDevelopment,
    @required Callback1<bool> callback,
  });
  void removeDeviceToken({
    @required String token,
    bool isDevelopment,
    @required Callback1<bool> callback,
  });
  void removeParticipants({
    @required int roomId,
    @required List<String> userIds,
    @required Callback1<List<String>> callback,
  });
  void sendFileMessage({
    @required QMessage message,
    @required File file,
    @required Callback2<QMessage, double> callback,
  });
  void sendMessage({
    @required QMessage message,
    @required Callback1<QMessage> callback,
  });
  void setCustomHeader(Map<String, String> headers);
  void setSyncInterval(double interval);
  void setup(
    String appId, {
    @required Callback0 callback,
  });
  void setupWithCustomServer(
    String appId, {
    String baseUrl,
    String brokerUrl,
    String brokerLbUrl,
    int syncInterval,
    int syncIntervalWhenConnected,
    @required Callback0 callback,
  });
  void setUser({
    @required String userId,
    @required String userKey,
    String username,
    String avatarUrl,
    Map<String, dynamic> extras,
    @required Callback1<QAccount> callback,
  });
  void setUserWithIdentityToken({
    @required String token,
    @required Callback1<QAccount> callback,
  });
  void unsubscribeChatRoom(QChatRoom room);
  void subscribeChatRoom(QChatRoom room);
  void subscribeCustomEvent({
    @required int roomId,
    @required void Function(Map<String, dynamic> payload) callback,
  });
  void unsubscribeCustomEvent({@required int roomId});
  void subscribeUserOnlinePresence(String userId);
  void unsubscribeUserOnlinePresence(String userId);
  void synchronize({String lastMessageId = '0'});
  void synchronizeEvent({String lastEventId = '0'});

  void unblockUser({
    @required String userId,
    @required Callback1<QUser> callback,
  });
  void updateChatRoom({
    @required int roomId,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
    @required Callback1<QChatRoom> callback,
  });
  void updateUser({
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
    @required Callback1<QAccount> callback,
  });
  void upload({
    @required File file,
    @required Callback2<String, double> callback,
  });

  QMessage generateMessage({
    @required int chatRoomId,
    @required String text,
    Map<String, dynamic> extras,
  });
  QMessage generateCustomMessage({
    @required int chatRoomId,
    @required String text,
    @required String type,
    Map<String, dynamic> extras,
    @required Map<String, dynamic> payload,
  });
  QMessage generateFileAttachmentMessage({
    @required int chatRoomId,
    @required String caption,
    @required String url,
    String filename,
    String text = 'File attachment',
    int size,
    Map<String, dynamic> extras,
  });

  // Room handler
  Subscription onChatRoomCleared(void Function(int) handler);

  // Message handler
  Subscription onMessageDeleted(void Function(QMessage) handler);
  Subscription onMessageDelivered(void Function(QMessage) handler);
  Subscription onMessageRead(void Function(QMessage) handler);
  Subscription onMessageReceived(void Function(QMessage) handler);

  // Realtime subscription handler
  Subscription onConnected(void Function() handler);
  Subscription onDisconnected(void Function() handler);
  Subscription onReconnecting(void Function() handler);

  // User handler
  Subscription onUserOnlinePresence(
    void Function(String userId, bool isOnline, DateTime lastSeen) handler,
  );
  Subscription onUserTyping(
    void Function(String userId, int roomId, bool isTyping) handler,
  );
}
