import '../../core.dart';

class QCustomEvent {
  QCustomEvent({
    required this.roomId,
    required this.payload,
  });
  final int roomId;
  final Json payload;
}
