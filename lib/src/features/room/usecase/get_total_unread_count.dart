import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository.dart';

class GetTotalUnreadCountUseCase
    extends UseCase<RoomRepository, int, NoParams> {
  GetTotalUnreadCountUseCase(RoomRepository repository) : super(repository);

  @override
  Task<Either<Exception, int>> call(_) {
    return repository.getTotalUnreadCount();
  }
}
