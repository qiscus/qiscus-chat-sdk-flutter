
import 'package:qiscus_chat_sdk/src/domain/user/user-model.dart';
import 'package:riverpod/riverpod.dart';

final platformNameProvider = Provider((_) => 'flutter');
final sdkVersionProvider = Provider((_) => '2.0.0-beta.1');
final accountProvider = Provider<QAccount?>((_) => null);