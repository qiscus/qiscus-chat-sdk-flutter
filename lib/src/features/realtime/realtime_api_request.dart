part of qiscus_chat_sdk.usecase.realtime;

class SynchronizeRequest extends IApiRequest<Tuple2<int, List<Message>>> {
  final int lastMessageId;

  SynchronizeRequest({
    this.lastMessageId = 0,
  });

  get url => 'sync';
  get method => IRequestMethod.get;
  get params => <String, dynamic>{
        'last_received_comment_id': lastMessageId,
      };

  format(json) {
    var lastId = json['results']['meta']['last_received_comment_id'] as int;
    var messages = (json['results']['comments'] as List)
        .cast<Map<String, dynamic>>()
        .map((it) => Message.fromJson(it))
        .toList();

    return tuple2(lastId, messages);
  }
}

class SynchronizeEventRequest
    extends IApiRequest<Tuple2<int, List<RealtimeEvent>>> {
  final int lastEventId;
  SynchronizeEventRequest({
    this.lastEventId = 0,
  });

  get url => 'sync_event';
  get method => IRequestMethod.get;
  get params => <String, dynamic>{
        'start_event_id': lastEventId,
      };

  format(json) {
    // FIXME: change the event id to the correct value
    return tuple2(123, RealtimeEvent.fromJson(json));
  }
}
