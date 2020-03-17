import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/features/sync/repository.dart';

import 'api.dart';

class SyncRepositoryImpl implements SyncRepository {
  @override
  Task<Either<Exception, SynchronizeResponse>> synchronize(
      [int lastMessageId = 0]) {
    return null;
  }

  @override
  Task<Either<Exception, SynchronizeEventResponse>> synchronizeEvent(
      [int eventId = 0]) {
    return null;
  }
}
