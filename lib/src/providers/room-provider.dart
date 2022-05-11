import 'package:qiscus_chat_sdk/src/impls/room/add-participants.dart';
import 'package:qiscus_chat_sdk/src/impls/room/get-room-with-messages-impl.dart';
import 'package:qiscus_chat_sdk/src/providers/http-client-provider.dart';
import 'package:riverpod/riverpod.dart';

import '../domain/user/user-model.dart';
import '../models/room-with-messages.dart';
import 'package:qiscus_chat_sdk/src/utils.dart';

final roomProvider =
    StateNotifierProvider.autoDispose.family((ref, int roomId) {
  return RoomStateNotifier(ref, roomId);
});

class RoomStateNotifier extends StateNotifier<AsyncValue<QChatRoom>> {
  final Ref ref;
  RoomStateNotifier(this.ref, int roomId) : super(const AsyncValue.loading()) {
    _fetch(roomId);
  }

  void _fetch(int roomId) async {
    state = AsyncValue.loading();

    var req = GetRoomByIdRequest(roomId: roomId);
    state = await AsyncValue.guard(() async {
      var res = await req(ref.read(httpClientProvider));
      var room = res.first;
      var messages = res.second.toList();

      var data = QChatRoom(
        id: room.id,
        name: room.name!,
        uniqueId: room.uniqueId,
        avatarUrl: room.avatarUrl,
        extras: room.extras,
        lastMessage: room.lastMessage,
        messages: messages,
        participants: room.participants,
        totalParticipants: room.totalParticipants,
        type: room.type,
        unreadCount: room.unreadCount,
      );
      return data;
    });
  }

  Future<List<QParticipant>> addParticipants(List<String> userIds) async {
    var roomId = await state.whenData((value) => value.id).future;
    var req = AddParticipantRequest(roomId: roomId, userIds: userIds);
    return req(ref.read(httpClientProvider))
        .then((it) => it.toList())
        .then((participants) {
      state = state.whenData((it) {
        var newParticipants = [...it.participants, ...participants];
        return it.copyWith(
          participants: newParticipants,
          totalParticipants: newParticipants.length,
        );
      });
      return participants;
    });
  }
}
