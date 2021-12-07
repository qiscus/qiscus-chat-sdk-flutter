import 'package:qiscus_chat_sdk/src/core.dart';
import 'package:qiscus_chat_sdk/src/message/message.dart';
import 'package:test/test.dart';

import 'jsons.dart';

void main() {
  group('SendMessageRequest', () {
    var request = SendMessageRequest(
      message: 'message',
      roomId: 1,
    );
    test('body', () {
      expect(request.url, 'post_comment');
      expect(request.method, IRequestMethod.post);

      expect(request.body['topic_id'], '1');
      expect(request.body['comment'], 'message');
      expect(request.body['type'], 'text');
      expect(request.body['unique_temp_id'], null);
      expect(request.body['payload'], null);
      expect(request.body['extras'], null);
    });

    test('format', () {
      var r = request.format(sendMessageJson);

      expect(r.chatRoomId, Option.some(15));
      expect(r.id, Option.some(6273));
      expect(r.uniqueId, Option.some('kPMUDSRRRVL0mbxM1xKT'));
      expect(r.sender.flatMap((it) => it.id), Option.some('jarjit@mail.com'));
    });
  });

  group('GetMessagesRequest', () {
    GetMessagesRequest request;

    setUp(() {
      request = GetMessagesRequest(
        messageId: 0,
        lastMessageId: 0,
      );
    });

    test('body', () {
      expect(request.url, 'load_comments');
      expect(request.method, IRequestMethod.get);
      expect(request.params['topic_id'], 0);
      expect(request.params['last_comment_id'], 0);
      expect(request.params['after'], false);
      expect(request.params['limit'], 20);
    });

    test('format', () {
      var r = request.format(getMessagesJson);

      expect(r.length, 1);
      var c = r.first;
      expect(c.chatRoomId, Option.some(15));
      expect(c.id, Option.some(6273));
      expect(c.text, Option.some('halo bro'));
      expect(c.sender.flatMap((it) => it.id), Option.some('jarjit@mail.com'));
    });
  });

  group('UpdateMessageStatusRequest', () {
    UpdateMessageStatusRequest request1;
    UpdateMessageStatusRequest request2;

    setUp(() {
      request1 = markMessageAsRead(roomId: 0, messageId: 1);
      request2 = markMessageAsDelivered(roomId: 0, messageId: 1);
    });

    test('body', () {
      expect(request1.url, 'update_comment_status');
      expect(request1.method, IRequestMethod.post);
      expect(request1.body['room_id'], '0');
      expect(request1.body['last_comment_read_id'], '1');
      expect(request1.body['last_comment_received_id'], null);

      expect(request2.body['room_id'], '0');
      expect(request2.body['last_comment_read_id'], null);
      expect(request2.body['last_comment_received_id'], '1');
    });

    test('format', () {
      request1.format(updateCommentStatusJson);
    });
  });

  group('DeleteMessagesRequest', () {
    DeleteMessagesRequest request;

    setUp(() {
      request = DeleteMessagesRequest(uniqueIds: ['123']);
    });

    test('body', () {
      expect(request.url, 'delete_messages');
      expect(request.method, IRequestMethod.delete);
      expect(request.params['unique_ids'][0], '123');
      expect(request.params['is_hard_delete'], true);
      expect(request.params['is_delete_for_everyone'], true);
    });

    test('format', () {
      var r = request.format(deleteCommentsJson);

      expect(r.length, 2);
      var c = r.first;
      expect(c.chatRoomId, Option.some(17));
      expect(c.id, Option.some(6276));
      expect(c.text, Option.some('This message has been deleted.'));
      expect(c.sender.flatMap((a) => a.id), Option.some('jarjit@mail.com'));
    });
  });
}
