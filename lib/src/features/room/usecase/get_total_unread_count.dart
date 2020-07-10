import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository.dart';

class GetTotalUnreadCountUseCase
    extends UseCase<IRoomRepository, int, NoParams> {
  GetTotalUnreadCountUseCase(IRoomRepository repository) : super(repository);

  @override
  Task<Either<QError, int>> call(_) {
    return repository.getTotalUnreadCount();
  }
}
