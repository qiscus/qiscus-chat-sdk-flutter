part of qiscus_chat_sdk.usecase.room;

class CreateGroupChatParams {
  const CreateGroupChatParams({
    @required this.name,
    @required this.userIds,
    this.avatarUrl,
    this.extras,
  });
  final String name;
  final List<String> userIds;
  final String avatarUrl;
  final Map<String, dynamic> extras;
}

class CreateGroupChatUseCase
    extends UseCase<IRoomRepository, ChatRoom, CreateGroupChatParams> {
  CreateGroupChatUseCase(IRoomRepository repository) : super(repository);

  @override
  Task<Either<QError, ChatRoom>> call(p) {
    return repository.createGroup(
      name: p.name,
      userIds: p.userIds,
      avatarUrl: p.avatarUrl,
      extras: p.extras,
    );
  }
}
