import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';
import 'package:qiscus_chat_sdk/src/core/storage.dart';
import 'package:qiscus_chat_sdk/src/core/usecases.dart';
import 'package:qiscus_chat_sdk/src/features/message/entity.dart';
import 'package:qiscus_chat_sdk/src/features/sync/repository.dart';

@immutable
class SynchronizeParams {
  final int lastMessageId;
  final int eventId;
  const SynchronizeParams({this.lastMessageId, this.eventId});
}

@immutable
class SynchronizeResponse {
  final int lastMessageId;
  final List<Message> messages;
  SynchronizeResponse({this.lastMessageId, this.messages});
}

enum SyncEventAction {
  message_read,
  message_delivered,
  message_deleted,
  room_cleared,
}

class SynchronizeEventResponse {
  final SyncEventAction action;
  final int roomId;
  final QMessage message;
  SynchronizeEventResponse({this.action, this.message, this.roomId});
}

@immutable
class Synchronize
    extends UseCase<SyncRepository, SynchronizeResponse, SynchronizeParams> {
  final Storage _storage;
  const Synchronize(SyncRepository repository, this._storage)
      : super(repository);

  @override
  Task<Either<Exception, SynchronizeResponse>> call(params) {
    return repository
        .synchronize(params.lastMessageId)
        .leftMapToException()
        .tap(
          (res) => _storage.lastMessageId = res.lastMessageId,
        )
        .rightMap(
          (res) => SynchronizeResponse(
            lastMessageId: res.lastMessageId,
            messages: res.messages,
          ),
        );
  }
}

@immutable
class SynchronizeEvent extends UseCase<SyncRepository, SynchronizeEventResponse,
    SynchronizeParams> {
  SynchronizeEvent(SyncRepository repository) : super(repository);

  @override
  Task<Either<Exception, SynchronizeEventResponse>> call(params) {
    return repository
        .synchronizeEvent(params.eventId)
        .leftMapToException()
        .rightMap((res) => SynchronizeEventResponse());
  }
}
