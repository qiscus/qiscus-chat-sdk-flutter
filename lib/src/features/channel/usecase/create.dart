import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

import '../../../core/core.dart';
import '../../room/repository.dart';
import '../../room/room.dart';

@sealed
class GetOrCreateChannelParams {
  const GetOrCreateChannelParams(
    this.uniqueId, {
    this.name,
    this.avatarUrl,
    this.options,
  });
  final String uniqueId;
  final String name;
  final String avatarUrl;
  final Map<String, dynamic> options;
}

class GetOrCreateChannelUseCase
    extends UseCase<IRoomRepository, ChatRoom, GetOrCreateChannelParams> {
  GetOrCreateChannelUseCase(IRoomRepository repository) : super(repository);

  @override
  Task<Either<QError, ChatRoom>> call(GetOrCreateChannelParams p) {
    return repository.getOrCreateChannel(
      uniqueId: p.uniqueId,
      name: p.name,
      avatarUrl: p.avatarUrl,
      options: p.options,
    );
  }
}
