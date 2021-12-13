class QCustomEvent {
  QCustomEvent({
    required this.roomId,
    required this.payload,
  });
  final int roomId;
  final Map<String, dynamic> payload;
}
