export 'entity/account.dart';
export 'entity/participant.dart';
export 'entity/user.dart';
export 'repository.dart';
export 'repository_impl.dart';
export 'usecases/authenticate.dart';
export 'usecases/authenticate_with_token.dart';
export 'usecases/block_user.dart';
export 'usecases/get_blocked_user.dart';
export 'usecases/get_nonce.dart';
export 'usecases/get_user_data.dart';
export 'usecases/get_users.dart';
export 'usecases/realtime.dart';
export 'usecases/register_device_token.dart';
export 'usecases/unblock_user.dart';
export 'usecases/unregister_device_token.dart';
export 'usecases/update_user.dart';

import 'package:meta/meta.dart';

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
