import 'package:equatable/equatable.dart';

import '../../core.dart';

class QCustomEvent with EquatableMixin {
  QCustomEvent({
    required this.roomId,
    required this.payload,
  });
  final int roomId;
  final Json payload;

  @override
  List<Object?> get props => [roomId, payload];
}
