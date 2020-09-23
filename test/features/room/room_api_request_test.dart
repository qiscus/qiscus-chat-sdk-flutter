import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/features/room/room.dart';
import 'package:test/test.dart';

import 'backend_response.dart';
import 'json.dart';

void main() {
  group('ChatTargetRequest', () {
    var response = chatTargetResponse;
    var room = response['results']['room'] as Map<String, dynamic>;
    ChatTargetRequest request;

    setUp(() {
      request = ChatTargetRequest(userId: 'guest-101');
    });

    test('body', () {
      expect(request.url, 'get_or_create_room_with_target');
      expect(request.method, IRequestMethod.post);
      expect(request.body['emails'], ['guest-101']);
    });
    test('format', () {
      var data = request.format(response);
      expect(data.id, some(room['id'] as int));
      expect(data.name, some(room['room_name'] as String));
      expect(data.uniqueId, some(room['unique_id'] as String));
    });
  });

  group('GetRoomById', () {
    var response = getRoomByIdResponse;
    var room = response['results']['room'] as Map<String, dynamic>;
    var messages =
        (response['results']['comments'] as List).cast<Map<String, dynamic>>();
    GetRoomByIdRequest request;

    setUp(() {
      request = GetRoomByIdRequest(roomId: 123);
    });

    test('body', () {
      expect(request.url, 'get_room_by_id');
      expect(request.method, IRequestMethod.get);
      expect(request.params['id'], 123);
    });

    test('format', () {
      var data = request.format(response);
      expect(data.value1.id, some(room['id'] as int));
      expect(data.value1.uniqueId, some(room['unique_id'] as String));

      expect(data.value2.length, 1);
      expect(data.value2.first.id, some(messages.first['id'] as int));
      expect(data.value2.first.uniqueId,
          some(messages.first['unique_temp_id'] as String));
    });
  });

  group('AddParticipantRequest', () {
    var response = addParticipantResponse;
    var participants = (response['results']['participants_added'] as List)
        .cast<Map<String, dynamic>>();

    AddParticipantRequest request;
    setUp(() {
      request = AddParticipantRequest(roomId: 123, userIds: ['guest-101']);
    });

    test('body', () {
      expect(request.url, 'add_room_participants');
      expect(request.method, IRequestMethod.post);
      expect(request.body['room_id'], '123');
      expect(request.body['emails'], ['guest-101']);
    });

    test('format', () {
      var data = request.format(response);
      expect(data.first.id, participants.first['email']);
      expect(data.first.name, some(participants.first['username'] as String));
    });
  });

  group('RemoveParticipantRequest', () {
    var response = removeParticipantResponse;
    var userIds = (response['results']['participants_removed'] as List) //
        .cast<String>();
    RemoveParticipantRequest request;

    setUp(() {
      request = RemoveParticipantRequest(roomId: 123, userIds: ['guest-101']);
    });

    test('body', () {
      expect(request.url, 'remove_room_participants');
      expect(request.method, IRequestMethod.post);
      expect(request.body['room_id'], '123');
      expect(request.body['emails'], ['guest-101']);
    });

    test('format', () {
      var data = request.format(response);
      expect(data.first, userIds.first);
    });
  });

  group('GetParticipantRequest', () {
    var response = getParticipantResponse;
    var participants = (response['results']['participants'] as List) //
        .cast<Map<String, dynamic>>();
    GetParticipantRequest request;

    setUp(() {
      request = GetParticipantRequest(roomUniqueId: '123');
    });

    test('body', () {
      expect(request.url, 'room_participants');
      expect(request.method, IRequestMethod.get);
      expect(request.params['room_unique_id'], '123');
      expect(request.params['page'], null);
      expect(request.params['limit'], null);
      expect(request.params['sorting'], null);
    });

    test('format', () {
      var data = request.format(response);
      expect(data.first.id, participants.first['email']);
      expect(data.first.name, some(participants.first['email'] as String));
    });
  });

  group('GetAllRoomRequest', () {
    var response = getAllRoomResponse;
    var rooms = (response['results']['rooms_info'] as List) //
        .cast<Map<String, dynamic>>();
    GetAllRoomRequest request;

    setUp(() {
      request = GetAllRoomRequest();
    });

    test('body', () {
      expect(request.url, 'user_rooms');
      expect(request.method, IRequestMethod.get);

      expect(request.params['page'], null);
      expect(request.params['limit'], null);
      expect(request.params['show_participants'], null);
      expect(request.params['show_empty'], null);
      expect(request.params['show_removed'], null);
    });
    test('format', () {
      var data = request.format(response);
      expect(data.first.uniqueId, some(rooms.first['unique_id'] as String));
      expect(data.first.id, some(rooms.first['id'] as int));
      expect(data.first.name, some(rooms.first['room_name'] as String));
    });
  });

  group('GetOrCreateChannelRequest', () {
    var response = getOrCreateChannelResponse;
    GetOrCreateChannelRequest request;

    setUp(() {
      request = GetOrCreateChannelRequest(uniqueId: 'unique-id');
    });

    test('body', () {
      expect(request.url, 'get_or_create_room_with_unique_id');
      expect(request.method, IRequestMethod.post);

      expect(request.body['unique_id'], 'unique-id');
      expect(request.body['avatar_url'], null);
      expect(request.body['options'], null);
      expect(request.body['name'], null);
    });
    test('format', () {
      var data = request.format(response);
      var room = response['results']['room'] as Map<String, dynamic>;

      expect(data.uniqueId, some(room['unique_id'] as String));
      expect(data.name, some(room['room_name'] as String));
      expect(data.id, some(room['id'] as int));
    });
  });

  group('CreateGroupRequest', () {
    CreateGroupRequest request;

    setUp(() {
      request = CreateGroupRequest(name: 'name', userIds: ['guest']);
    });

    test('body', () {
      expect(request.url, 'create_room');
      expect(request.method, IRequestMethod.post);

      expect(request.body['name'], 'name');
      expect(request.body['participants'], ['guest']);
      expect(request.body['avatar_url'], null);
      expect(request.body['options'], null);
    });

    test('format', () {
      var data = request.format(createGroupResponse);
      var room = createGroupResponse['results']['room'] as Map<String, dynamic>;

      expect(data.uniqueId, some(room['unique_id'] as String));
      expect(data.id, some(room['id'] as int));
      expect(data.name, some(room['room_name'] as String));
      expect(data.avatarUrl, some(room['avatar_url'] as String));
    });
  });

  group('ClearMessagesRequest', () {
    final request = ClearMessagesRequest(roomUniqueIds: ['1234']);
    test('body', () {
      expect(request.url, 'clear_room_messages');
      expect(request.method, IRequestMethod.delete);

      expect(
          (request.params['room_channel_ids'] as List<String>).first, '1234');
    });

    test('format', () {
      var json = clearRoomJson;
      // var data = (json['results']['rooms'] as List).cast<Map<String, dynamic>>().first;

      var r = request.format(json);
      expect(r, unit);
    });
  });

  group('GetRoomInfoRequest', () {
    final request = GetRoomInfoRequest(
      roomIds: [123],
      uniqueIds: ['123'],
      withParticipants: false,
      withRemoved: false,
      page: 1,
    );
    test('body', () {
      expect(request.url, 'rooms_info');
      expect(request.method, IRequestMethod.post);
      expect((request.body['room_id'] as List).first, '123');
      expect((request.body['room_unique_id'] as List).first, '123');
      expect(request.body['show_participants'], false);
      expect(request.body['show_removed'], false);
    });
    test('format', () {
      var json = roomInfoJson;

      var r = request.format(json);

      expect(r.length, 1);

      var room = r.first;
      var data = (json['results']['rooms_info'] as List)
          .cast<Map<String, dynamic>>()
          .first;
      expect(room.id, some(data['id'] as int));
      expect(room.name, some(data['room_name'] as String));
    });
  });

  group('GetTotalUnreadCount', () {
    final request = GetTotalUnreadCountRequest();

    test('body', () {
      expect(request.url, 'total_unread_count');
      expect(request.method, IRequestMethod.get);
    });
    test('format', () {
      var json = totalUnreadCountJson;

      var r = request.format(json);
      expect(r, json['results']['total_unread_count']);
    });
  });

  group('UpdateRoomRequest', () {
    final request = UpdateRoomRequest(
      roomId: '123',
      name: 'asd',
      avatarUrl: 'avatar-url',
      extras: <String, dynamic>{
        'key': 11,
      },
    );

    test('body', () {
      expect(request.url, 'update_room');
      expect(request.method, IRequestMethod.post);

      var extras = jsonDecode(request.body['options'] as String) as Map<String, dynamic>;
      expect(request.body['id'], '123');
      expect(request.body['name'], 'asd');
      expect(request.body['avatar_url'], 'avatar-url');
      expect(extras.keys.length, 1);
      expect(extras['key'], 11);
    });

    test('format', () {
      var json = updateRoomJson;
      var room = json['results']['room'] as Map<String, dynamic>;

      var r = request.format(json);
      expect(r.name, some(room['room_name'] as String));
      expect(r.id, some(room['id'] as int));
    });
  });
}
