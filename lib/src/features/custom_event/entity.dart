import 'package:meta/meta.dart';

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
