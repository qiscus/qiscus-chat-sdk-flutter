import 'package:dartz/dartz.dart';

import 'api.dart';

abstract class SyncRepository {
  Task<Either<Exception, SynchronizeResponse>> synchronize([
    int lastMessageId = 0,
  ]);
  Task<Either<Exception, SynchronizeEventResponse>> synchronizeEvent([
    int eventId = 0,
  ]);
}
