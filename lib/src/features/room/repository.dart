import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/features/message/message.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';

import 'entity.dart';

abstract class IRoomRepository {
  Task<Either<QError, ChatRoom>> getRoomWithUserId({
    @required String userId,
    Map<String, dynamic> extras,
  });

  Task<Either<QError, Tuple2<ChatRoom, List<Message>>>> getRoomWithId(
      int roomId);

  Task<Either<QError, List<Participant>>> addParticipant(
    int roomId,
    List<String> participantIds,
  );

  Task<Either<QError, List<String>>> removeParticipant(
    int roomId,
    List<String> participantIds,
  );

  Task<Either<QError, List<Participant>>> getParticipants(
    String uniqueId,
  );

  Task<Either<QError, List<ChatRoom>>> getAllRooms({
    bool withParticipants,
    bool withEmptyRoom,
    bool withRemovedRoom,
    int limit,
    int page,
  });

  Task<Either<QError, ChatRoom>> getOrCreateChannel({
    @required String uniqueId,
    String name,
    String avatarUrl,
    Map<String, dynamic> options,
  });

  Task<Either<QError, ChatRoom>> createGroup({
    @required String name,
    @required List<String> userIds,
    String avatarUrl,
    Map<String, dynamic> extras,
  });

  Task<Either<QError, Unit>> clearMessages({
    @required List<String> uniqueIds,
  });

  Task<Either<QError, List<ChatRoom>>> getRoomInfo({
    List<int> roomIds,
    List<String> uniqueIds,
    bool withParticipants,
    bool withRemoved,
    int page,
  });

  Task<Either<QError, int>> getTotalUnreadCount();

  Task<Either<QError, ChatRoom>> updateRoom({
    @required int roomId,
    String name,
    String avatarUrl,
    Map<String, dynamic> extras,
  });
}
