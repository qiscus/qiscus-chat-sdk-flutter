part of qiscus_chat_sdk.usecase.room;

class ParticipantParams {
  const ParticipantParams(this.roomId, this.participantIds);

  final int roomId;
  final List<String> participantIds;
}

class AddParticipantUseCase
    extends UseCase<IRoomRepository, List<Participant>, ParticipantParams> {
  AddParticipantUseCase(IRoomRepository repository) : super(repository);

  @override
  Task<Either<QError, List<Participant>>> call(params) {
    return repository.addParticipant(params.roomId, params.participantIds);
  }
}

class RemoveParticipantUseCase
    extends UseCase<IRoomRepository, List<String>, ParticipantParams> {
  RemoveParticipantUseCase(IRoomRepository repository) : super(repository);

  @override
  Task<Either<QError, List<String>>> call(ParticipantParams params) {
    return repository.removeParticipant(params.roomId, params.participantIds);
  }
}

class GetParticipantsUseCase
    extends UseCase<IRoomRepository, List<Participant>, RoomUniqueIdsParams> {
  GetParticipantsUseCase(IRoomRepository repository) : super(repository);

  @override
  Task<Either<QError, List<Participant>>> call(RoomUniqueIdsParams params) {
    return repository.getParticipants(params.uniqueId);
  }
}
