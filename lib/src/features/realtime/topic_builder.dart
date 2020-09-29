part of qiscus_chat_sdk.usecase.realtime;

abstract class TopicBuilder {
  static String typing(String roomId, String userId) =>
      'r/$roomId/$roomId/$userId/t';

  static String presence(String userId) => 'u/$userId/s';

  static String messageDelivered(String roomId) => 'r/$roomId/+/+/d';

  static String notification(String token) => '$token/n';

  static String messageRead(String roomId) => 'r/$roomId/+/+/r';

  static String messageNew(String token) => '$token/c';

  static String channelMessageNew(String appId, String channelId) =>
      '$appId/$channelId/c';

  static String customEvent(int roomId) => 'r/$roomId/$roomId/e';
}
