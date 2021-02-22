library qiscus_chat_sdk.usecase.message;

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/features/realtime/realtime.dart';

import '../../core.dart';
import '../../type_utils.dart';
import '../../features/user/user.dart';

part 'entity.dart';
part 'message_api_request.dart';
part 'repository.dart';
part 'repository_impl.dart';
part 'usecase/delete_message.dart';
part 'usecase/get_message_list.dart';
part 'usecase/realtime.dart';
part 'usecase/send_message.dart';
part 'usecase/update_message.dart';
part 'usecase/update_status.dart';
