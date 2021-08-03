library qiscus_chat_sdk.usecase.message;

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

import '../core.dart';
import '../type_utils.dart';
import '../realtime/realtime.dart';
import '../user/user.dart';

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
