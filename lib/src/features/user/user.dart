library qiscus_chat_sdk.usecase.user;

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../core.dart';
import '../../features/realtime/realtime.dart';

part 'entity/account.dart';
part 'entity/participant.dart';
part 'entity/user.dart';
part 'repository.dart';
part 'repository_impl.dart';
part 'usecases/authenticate.dart';
part 'usecases/authenticate_with_token.dart';
part 'usecases/block_user.dart';
part 'usecases/get_blocked_user.dart';
part 'usecases/get_nonce.dart';
part 'usecases/get_user_data.dart';
part 'usecases/get_users.dart';
part 'usecases/realtime.dart';
part 'usecases/register_device_token.dart';
part 'usecases/unblock_user.dart';
part 'usecases/update_user.dart';
part 'user_api_request.dart';

@sealed
@immutable
class UserTyping {
  UserTyping({
    @required this.userId,
    @required this.roomId,
    @required this.isTyping,
  });

  final String userId;
  final int roomId;
  final bool isTyping;
}

@sealed
@immutable
class UserPresence {
  UserPresence({
    @required this.userId,
    @required this.lastSeen,
    @required this.isOnline,
  });

  final String userId;
  final DateTime lastSeen;
  final bool isOnline;
}
