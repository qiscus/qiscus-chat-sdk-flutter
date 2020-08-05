var eventJson = <String, dynamic>{
  "events": [
    {
      "id": 1,
      "timestamp": "12345",
      "action_topic": "read",
      "payload": {
        "actor": {"id": "", "email": "", "name": ""},
        "data": {
          "comment_id": 123,
          "comment_unique_id": "123--",
          "email": "user-id",
          "room_id": 1234
        }
      }
    },
    {
      "id": 2,
      "timestamp": "12345",
      "action_topic": "delivered",
      "payload": {
        "actor": {"id": "", "email": "", "name": ""},
        "data": {
          "comment_id": 123,
          "comment_unique_id": "123--",
          "email": "user-id",
          "room_id": 1234
        }
      }
    },
    {
      "id": 3,
      "timestamp": "12345",
      "action_topic": "delete_messages",
      "payload": {
        "deleted_messages": [
          {
            "message_unique_ids": ["12345"],
            "room_id": "12345"
          }
        ],
        "is_hard_delete": true
      }
    },
    {
      "id": 4,
      "timestamp": "12345",
      "action_topic": "clear_room",
      "payload": {
        "deleted_rooms": [
          {
            "avatar_url": "room-avatar-url",
            "chat_type": "single",
            "id": 123,
            "id_str": "123",
            "last_comment": null,
            "options": <String, dynamic>{},
            "raw_room_name": "raw-room-name",
            "room_name": "room-name",
            "unique_id": "unique-id",
            "unread_count": 0
          }
        ]
      }
    }
  ],
  "is_start_event_id_found": true
};
