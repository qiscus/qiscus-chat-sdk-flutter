library qiscus_chat_sdk.usecase.room;

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/features/message/message.dart';
import 'package:qiscus_chat_sdk/src/features/user/user.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/realtime.dart';
import 'dart:convert';
import '../../core.dart';

part 'entity.dart';
part 'repository.dart';
part 'repository_impl.dart';
part 'usecase/clear_room_messages.dart';
part 'usecase/create_group.dart';
part 'usecase/get_room.dart';
part 'usecase/get_room_by_user_id.dart';
part 'usecase/get_room_info.dart';
part 'usecase/get_room_with_messages.dart';
part 'usecase/get_rooms.dart';
part 'usecase/get_total_unread_count.dart';
part 'usecase/participant.dart';
part 'usecase/update_room.dart';
part 'room_api_request.dart';
part 'room_formatter.dart';
