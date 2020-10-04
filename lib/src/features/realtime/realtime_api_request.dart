part of qiscus_chat_sdk.usecase.realtime;

class SynchronizeRequest extends IApiRequest<Tuple2<int, List<Message>>> {
  final int lastMessageId;

  SynchronizeRequest({
    this.lastMessageId = 0,
  });

  @override
  String get url => 'sync';
  @override
  IRequestMethod get method => IRequestMethod.get;
  @override
  Map<String, dynamic> get params => <String, dynamic>{
        'last_received_comment_id': lastMessageId,
      };

  @override
  Tuple2<int, List<Message>> format(json) {
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

  @override
  String get url => 'sync_event';
  @override
  IRequestMethod get method => IRequestMethod.get;
  @override
  Map<String, dynamic> get params => <String, dynamic>{
        'start_event_id': lastEventId,
      };

  @override
  Tuple2<int, List<RealtimeEvent>> format(json) {
    // FIXME: change the event id to the correct value
    final id = (json['events'] as List) //
        .cast<Map<String, dynamic>>()
        .last['id'] as int;
    return tuple2(id, RealtimeEvent.fromJson(json));
  }
}
