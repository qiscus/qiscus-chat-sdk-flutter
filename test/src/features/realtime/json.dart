var eventJson = <String, dynamic>{
  'events': [
    {
      'id': 1,
      'timestamp': '12345',
      'action_topic': 'read',
      'payload': {
        'actor': {'id': '', 'email': '', 'name': ''},
        'data': {
          'comment_id': 123,
          'comment_unique_id': '123--',
          'email': 'user-id',
          'room_id': 1234
        }
      }
    },
    {
      'id': 2,
      'timestamp': '12345',
      'action_topic': 'delivered',
      'payload': {
        'actor': {'id': '', 'email': '', 'name': ''},
        'data': {
          'comment_id': 123,
          'comment_unique_id': '123--',
          'email': 'user-id',
          'room_id': 1234
        }
      }
    },
    {
      'id': 3,
      'timestamp': '12345',
      'action_topic': 'delete_message',
      'payload': {
        'deleted_messages': [
          {
            'message_unique_ids': ['12345'],
            'room_id': '12345'
          }
        ],
        'is_hard_delete': true
      }
    },
    {
      'id': 4,
      'timestamp': '12345',
      'action_topic': 'clear_room',
      'payload': {
        'deleted_rooms': [
          {
            'avatar_url': 'room-avatar-url',
            'chat_type': 'single',
            'id': 123,
            'id_str': '123',
            'last_comment': null,
            'options': <String, dynamic>{},
            'raw_room_name': 'raw-room-name',
            'room_name': 'room-name',
            'unique_id': 'unique-id',
            'unread_count': 0
          }
        ]
      },
    },
    {
      'id': 4,
      'timestamp': '12345',
      'action_topic': 'clear_room_unknown',
      'payload': {
        'deleted_rooms': [
          {
            'avatar_url': 'room-avatar-url',
            'chat_type': 'single',
            'id': 123,
            'id_str': '123',
            'last_comment': null,
            'options': <String, dynamic>{},
            'raw_room_name': 'raw-room-name',
            'room_name': 'room-name',
            'unique_id': 'unique-id',
            'unread_count': 0
          }
        ]
      }
    }
  ],
  'is_start_event_id_found': true
};

const syncJson = <String, dynamic>{
  'status': 200,
  'results': {
    'meta': {'last_received_comment_id': 986, 'need_clear': false},
    'comments': [
      {
        'id': 986,
        'topic_id': 1,
        'room_id': 1,
        'room_name': 'group name or interlocutor name',
        'comment_before_id': 985,
        'message': 'Hello Post 2',
        'type': 'text',
        'payload': <String, dynamic>{},
        'extras': null, // or can be return json value if you input it
        'disable_link_preview': false,
        'email': 'f1@gmail.com',
        'username': 'f1',
        'user_avatar': {
          'avatar': {'url': 'http://imagebucket.com/image.jpg'}
        },
        'user_avatar_url': 'http://imagebucket.com/image.jpg',
        'timestamp': '2016-09-06T16:18:50+00:00',
        'unix_timestamp': 1489999170,
        'unique_temp_id': 'CanBeAnything1234321'
      },
      {
        'id': 985,
        'topic_id': 1,
        'room_id': 1,
        'room_name': 'group name or interlocutor name',
        'comment_before_id': 984,
        'disable_link_preview': false,
        'message': 'Hello Post 2',
        'type': 'text',
        'payload': <String, dynamic>{},
        'extras': null, // or can be return json value if you input it
        'username': 'f1',
        'email': 'f1@gmail.com',
        'user_avatar': {
          'avatar': {'url': 'http://imagebucket.com/image.jpg'}
        },
        'user_avatar_url': 'http://imagebucket.com/image.jpg',
        'timestamp': '2016-09-06T16:18:50+00:00',
        'unix_timestamp': 1489999170,
        'unique_temp_id': 'CanBeAnything1234321'
      }
    ]
  }
};

const mqttChannelJson = <String, dynamic>{
  'id': 3326,
  'comment_before_id': 2920,
  'message': 'Halo',
  'username': 'Zetra',
  'email': 'zetra1@gmail.com',
  'user_avatar':
      'https://qiscuss3.s3.amazonaws.com/uploads/d8cf89cba2be4953bcbb471778263e86/2.png',
  'timestamp': '2016-10-28T08:23:03Z',
  'unix_timestamp': 123456789,
  'created_at': '2016-10-28T08:23:03.074Z',
  'room_id': 207,
  'room_name': 'room name',
  'topic_id': 207,
  'unique_temp_id': 'android_1477642981693c5458b0531df164',
  'disable_link_preview': false,
  'chat_type': 'group'
};
const mqttMessageJson = <String, dynamic>{
  'id': 3326,
  'comment_before_id': 2920,
  'message': 'Halo',
  'username': 'Zetra',
  'email': 'zetra1@gmail.com',
  'user_avatar':
      'https://qiscuss3.s3.amazonaws.com/uploads/d8cf89cba2be4953bcbb471778263e86/2.png',
  'timestamp': '2016-10-28T08:23:03Z',
  'unix_timestamp': 123456789,
  'created_at': '2016-10-28T08:23:03.074Z',
  'room_id': 207,
  'room_name': 'room name',
  'topic_id': 207,
  'unique_temp_id': 'android_1477642981693c5458b0531df164',
  'disable_link_preview': false,
  'chat_type': 'group'
};

const mqttDeleteMessageJson = <String, dynamic>{
  'action_topic': 'delete_message',
  'payload': {
    'actor': {'id': 'user id', 'email': 'user email', 'name': 'user name'},
    'data': {
      'is_hard_delete': true,
      'deleted_messages': [
        {
          'room_id': '0',
          'message_unique_ids': ['abc', 'hdfjjhv']
        }
      ]
    }
  }
};
const mqttClearRoomJson = <String, dynamic>{
  'action_topic': 'clear_room',
  'payload': {
    'actor': {'id': 'user id', 'email': 'user email', 'name': 'user name'},
    'data': {
      'deleted_rooms': [
        {
          'avatar_url':
              'https://qiscuss3.s3.amazonaws.com/uploads/55c0c6ee486be6b686d52e5b9bbedbbf/2.png',
          'chat_type': 'single',
          'id': 80,
          'id_str': '80',
          'options': <String, dynamic>{},
          'raw_room_name': 'asasmoyo@outlook.com kotak@outlook.com',
          'room_name': 'kotak',
          'unique_id': '72058999c5d64c61bca7dedd53963aa1',
          'last_comment': null
        }
      ]
    }
  }
};
