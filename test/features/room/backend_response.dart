import 'package:qiscus_chat_sdk/src/features/message/message.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';

const chatTargetResponse = <String, dynamic>{
  'results': {
    'comments': [
      {
        'comment_before_id': 275125827,
        'comment_before_id_str': '275125827',
        'disable_link_preview': false,
        'email': 'guest-1001',
        'extras': <String, dynamic>{},
        'id': 282543832,
        'id_str': '282543832',
        'is_deleted': false,
        'is_public_channel': false,
        'message': 'text message ini',
        'payload': {
          'content': {'p1': 'p1-value'},
          'type': 'tipe-message'
        },
        'room_avatar':
            'https://d1edrlpyc25xu0.cloudfront.net/kiwari-prod/image/upload/75r6s_jOHa/1507541871-avatar-mine.png',
        'room_id': 3148043,
        'room_id_str': '3148043',
        'room_name': 'guest-1001 guest-101',
        'room_type': 'single',
        'status': 'read',
        'timestamp': '2020-06-12T07:28:04Z',
        'topic_id': 3148043,
        'topic_id_str': '3148043',
        'type': 'custom',
        'unique_temp_id': 'flutter-1591946881639',
        'unix_nano_timestamp': 1591946884814314000,
        'unix_timestamp': 1591946884,
        'user_avatar': {
          'avatar': {
            'url':
                'https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/GoLdHEInn5/Screenshot+(11).png'
          }
        },
        'user_avatar_url':
            'https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/GoLdHEInn5/Screenshot+(11).png',
        'user_extras': {'extras': true},
        'user_id': 44465689,
        'user_id_str': '44465689',
        'username': 'guest-1001'
      },
    ],
    'room': {
      'avatar_url':
          'https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/P8AQ0Dkjxb/162.png',
      'chat_type': 'single',
      'id': 3148043,
      'id_str': '3148043',
      'is_public_channel': false,
      'last_comment_id': 282543832,
      'last_comment_id_str': '282543832',
      'last_comment_message': 'text message ini',
      'last_topic_id': 3148043,
      'last_topic_id_str': '3148043',
      'options': '{}',
      'participants': [
        {
          'active': true,
          'avatar_url':
              'https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/P8AQ0Dkjxb/162.png',
          'email': 'guest-101',
          'extras': {'title': 'senior manager'},
          'id': 32230310,
          'id_str': '32230310',
          'last_comment_read_id': 282543832,
          'last_comment_read_id_str': '282543832',
          'last_comment_received_id': 282543832,
          'last_comment_received_id_str': '282543832',
          'username': 'guest-101'
        },
        {
          'active': true,
          'avatar_url':
              'https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/GoLdHEInn5/Screenshot+(11).png',
          'email': 'guest-1001',
          'extras': {'extras': true},
          'id': 44465689,
          'id_str': '44465689',
          'last_comment_read_id': 282543832,
          'last_comment_read_id_str': '282543832',
          'last_comment_received_id': 282543832,
          'last_comment_received_id_str': '282543832',
          'username': 'guest-1001'
        }
      ],
      'raw_room_name': 'guest-1001 guest-101',
      'room_name': 'guest-101',
      'room_total_participants': 2,
      'unique_id': '578b0598688e665685a75c50b252e998',
      'unread_count': 0
    }
  },
  'status': 200
};

const getRoomByIdResponse = <String, dynamic>{
  'results': {
    'comments': [
      {
        'comment_before_id': 307408358,
        'comment_before_id_str': '307408358',
        'disable_link_preview': false,
        'email': 'guest-1001',
        'extras': <String, dynamic>{},
        'id': 307408449,
        'id_str': '307408449',
        'is_deleted': false,
        'is_public_channel': false,
        'message': 'abcdefghijklmn',
        'payload': <String, dynamic>{},
        'room_avatar':
            'https://d1edrlpyc25xu0.cloudfront.net/kiwari-prod/image/upload/75r6s_jOHa/1507541871-avatar-mine.png',
        'room_id': 4411750,
        'room_id_str': '4411750',
        'room_name': 'guest-1001 guest-1003',
        'room_type': 'single',
        'status': 'delivered',
        'timestamp': '2020-07-07T07:36:09Z',
        'topic_id': 4411750,
        'topic_id_str': '4411750',
        'type': 'text',
        'unique_temp_id': '1594107369344',
        'unix_nano_timestamp': 1594107369592572000,
        'unix_timestamp': 1594107369,
        'user_avatar': {
          'avatar': {
            'url':
                'https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/GoLdHEInn5/Screenshot+(11).png'
          }
        },
        'user_avatar_url':
            'https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/GoLdHEInn5/Screenshot+(11).png',
        'user_extras': {'extras': true},
        'user_id': 44465689,
        'user_id_str': '44465689',
        'username': 'guest-1001'
      }
    ],
    'is_participant': true,
    'room': {
      'avatar_url':
          'https://d1edrlpyc25xu0.cloudfront.net/kiwari-prod/image/upload/75r6s_jOHa/1507541871-avatar-mine.png',
      'chat_type': 'single',
      'id': 4411750,
      'id_str': '4411750',
      'is_public_channel': false,
      'last_comment_id': 307408449,
      'last_comment_id_str': '307408449',
      'last_comment_message': 'abcdefghijklmn',
      'last_topic_id': 4411750,
      'last_topic_id_str': '4411750',
      'options': '{}',
      'participants': [
        {
          'active': true,
          'avatar_url':
              'https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/GoLdHEInn5/Screenshot+(11).png',
          'email': 'guest-1001',
          'extras': {'extras': true},
          'id': 44465689,
          'id_str': '44465689',
          'last_comment_read_id': 307408449,
          'last_comment_read_id_str': '307408449',
          'last_comment_received_id': 307408449,
          'last_comment_received_id_str': '307408449',
          'username': 'guest-1001'
        },
        {
          'active': true,
          'avatar_url':
              'https://d1edrlpyc25xu0.cloudfront.net/kiwari-prod/image/upload/75r6s_jOHa/1507541871-avatar-mine.png',
          'email': 'guest-1003',
          'extras': <String, dynamic>{},
          'id': 51613505,
          'id_str': '51613505',
          'last_comment_read_id': 307389980,
          'last_comment_read_id_str': '307389980',
          'last_comment_received_id': 307408449,
          'last_comment_received_id_str': '307408449',
          'username': 'guest-1003'
        }
      ],
      'raw_room_name': 'guest-1001 guest-1003',
      'room_name': 'guest-1003',
      'room_total_participants': 2,
      'unique_id': 'b5b393a9aac1e1186914e10dc399cb6f',
      'unread_count': 0
    }
  },
  'status': 200
};

const addParticipantResponse = <String, dynamic>{
  'results': {
    'participants_added': [
      {
        'active': true,
        'avatar_url':
            'https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/1nOC-hvaQx/Screenshot_8.png',
        'email': 'guest-1002',
        'extras': <String, dynamic>{},
        'id': 44465688,
        'id_str': '44465688',
        'last_comment_read_id': 0,
        'last_comment_read_id_str': '0',
        'last_comment_received_id': 329036849,
        'last_comment_received_id_str': '329036849',
        'username': 'guest-1002'
      }
    ]
  },
  'status': 200
};

const removeParticipantResponse = <String, dynamic>{
  'results': {
    'participants_removed': ['guest-1002']
  },
  'status': 200
};

const getParticipantResponse = <String, dynamic>{
  'results': {
    'meta': {
      'current_offset': 0,
      'current_page': 0,
      'per_page': 100,
      'total': 94
    },
    'participants': [
      {
        'active': true,
        'avatar_url': 'https://',
        'email': '5DC8b51f0ae4885fe95953f9',
        'extras': <String, dynamic>{},
        'id': 187804661,
        'id_str': '187804661',
        'last_comment_read_id': 0,
        'last_comment_read_id_str': '0',
        'last_comment_received_id': 329036849,
        'last_comment_received_id_str': '329036849',
        'username': '5DC8b51f0ae4885fe95953f9'
      }
    ],
  },
  'status': 200
};

const getAllRoomResponse = <String, dynamic>{
  'results': {
    'meta': {'current_page': 1, 'total_room': 0},
    'rooms_info': [
      {
        'avatar_url':
            'https://d1edrlpyc25xu0.cloudfront.net/kiwari-prod/image/upload/E2nVru1t25/1507541900-avatar.png',
        'chat_type': 'group',
        'id': 20333514,
        'id_str': '20333514',
        'is_public_channel': false,
        'is_removed': false,
        'last_comment': {
          'comment_before_id': 0,
          'comment_before_id_str': '0',
          'disable_link_preview': false,
          'email': 'guest-101',
          'extras': <String, dynamic>{},
          'id': 329153047,
          'id_str': '329153047',
          'is_deleted': false,
          'is_public_channel': false,
          'message': 'test',
          'payload': <String, dynamic>{},
          'room_avatar':
              'https://d1edrlpyc25xu0.cloudfront.net/kiwari-prod/image/upload/E2nVru1t25/1507541900-avatar.png',
          'room_id': 20333514,
          'room_id_str': '20333514',
          'room_name': 'coba-group',
          'room_type': 'group',
          'status': 'sent',
          'timestamp': '2020-07-27T06:05:18Z',
          'topic_id': 20333514,
          'topic_id_str': '20333514',
          'type': 'text',
          'unique_temp_id': '1595829918247',
          'unix_nano_timestamp': 1595829918293407000,
          'unix_timestamp': 1595829918,
          'user_avatar': {
            'avatar': {
              'url':
                  'https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/P8AQ0Dkjxb/162.png'
            }
          },
          'user_avatar_url':
              'https://d1edrlpyc25xu0.cloudfront.net/sdksample/image/upload/P8AQ0Dkjxb/162.png',
          'user_extras': <String, dynamic>{},
          'user_id': 32230310,
          'user_id_str': '32230310',
          'username': 'guest-101'
        },
        'options': '{}',
        'raw_room_name': 'coba-group',
        'room_name': 'coba-group',
        'unique_id': 'bb813c48-2f3b-4a58-af86-0056e875b0b1',
        'unread_count': 1
      }
    ]
  },
  'status': 200
};

const getOrCreateChannelResponse = <String, dynamic>{
  'results': {
    'changed': true,
    'comments': <Message>[],
    'room': {
      'avatar_url':
          'https://d1edrlpyc25xu0.cloudfront.net/kiwari-prod/image/upload/E2nVru1t25/1507541900-avatar.png',
      'chat_type': 'group',
      'id': 20335700,
      'id_str': '20335700',
      'is_public_channel': true,
      'last_comment_id': 0,
      'last_comment_id_str': '0',
      'last_comment_message': '',
      'last_topic_id': 20335700,
      'last_topic_id_str': '20335700',
      'options': '{}',
      'participants': <Participant>[],
      'raw_room_name': 'guest-1021',
      'room_name': 'guest-1021',
      'room_total_participants': 0,
      'unique_id': 'guest-1021',
      'unread_count': 0
    }
  },
  'status': 200
};

const createGroupResponse = <String, dynamic>{
  'results': {
    'comments': <Message>[],
    'room': {
      'avatar_url':
          'https://d1edrlpyc25xu0.cloudfront.net/kiwari-prod/image/upload/E2nVru1t25/1507541900-avatar.png',
      'chat_type': 'group',
      'id': 20336421,
      'id_str': '20336421',
      'is_public_channel': false,
      'last_comment_id': 0,
      'last_comment_id_str': '0',
      'last_comment_message': '',
      'last_topic_id': 20336421,
      'last_topic_id_str': '20336421',
      'options': '{}',
      'participants': [
        {
          'active': true,
          'avatar_url': 'https://via.placeholder.com/200',
          'email': 'guest-1001',
          'extras': {'key': 'value'},
          'id': 44465689,
          'id_str': '44465689',
          'last_comment_read_id': 0,
          'last_comment_read_id_str': '0',
          'last_comment_received_id': 0,
          'last_comment_received_id_str': '0',
          'username': 'guest-1001'
        }
      ],
      'raw_room_name': 'group test name',
      'room_name': 'group test name',
      'room_total_participants': 1,
      'unique_id': 'af718330-2994-45c8-8be5-1d8e4800dd11',
      'unread_count': 0
    }
  },
  'status': 200
};
