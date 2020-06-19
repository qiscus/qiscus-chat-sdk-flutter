import 'package:dartz/dartz.dart';
import 'package:qiscus_chat_sdk/src/core/core.dart';
import 'package:qiscus_chat_sdk/src/features/message/message.dart';
import 'package:qiscus_chat_sdk/src/features/room/repository.dart';
import 'package:qiscus_chat_sdk/src/features/room/room.dart';
import 'package:qiscus_chat_sdk/src/features/user/entity/participant.dart';

class ParticipantParams {
  const ParticipantParams(this.roomId, this.participantIds);

  final int roomId;
  final List<String> participantIds;
}

class AddParticipantUseCase
    extends UseCase<RoomRepository, List<Participant>, ParticipantParams> {
  AddParticipantUseCase(RoomRepository repository) : super(repository);

  @override
  Task<Either<QError, List<Participant>>> call(params) {
    return repository
        .addParticipant(params.roomId, params.participantIds)
        .rightMap((res) => res.participants);
  }
}

class RemoveParticipantUseCase
    extends UseCase<RoomRepository, List<String>, ParticipantParams> {
  RemoveParticipantUseCase(RoomRepository repository) : super(repository);

  @override
  Task<Either<QError, List<String>>> call(ParticipantParams params) {
    return repository
        .removeParticipant(params.roomId, params.participantIds)
        .rightMap((res) => res.participantIds);
  }
}

class GetParticipantsUseCase
    extends UseCase<RoomRepository, List<Participant>, RoomUniqueIdsParams> {
  GetParticipantsUseCase(RoomRepository repository) : super(repository);

  @override
  Task<Either<QError, List<Participant>>> call(RoomUniqueIdsParams params) {
    return repository
        .getParticipants(params.uniqueId)
        .rightMap((res) => res.participants);
  }
}
