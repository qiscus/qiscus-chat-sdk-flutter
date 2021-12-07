part of qiscus_chat_sdk.usecase.message;




UpdateMessageStatusRequest markMessageAsRead({
  @required int roomId,
  @required int messageId,
}) {
  return UpdateMessageStatusRequest(
    messageId: roomId,
    lastReadId: messageId,
  );
}

UpdateMessageStatusRequest markMessageAsDelivered({
  @required int roomId,
  @required int messageId,
}) {
  return UpdateMessageStatusRequest(
    messageId: roomId,
    lastDeliveredId: messageId,
  );
}
