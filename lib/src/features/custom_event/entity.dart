part of qiscus_chat_sdk.usecase.custom_event;

@sealed
@immutable
class CustomEvent {
  CustomEvent({
    @required this.roomId,
    @required this.payload,
  });
  final int roomId;
  final Map<String, dynamic> payload;
}
