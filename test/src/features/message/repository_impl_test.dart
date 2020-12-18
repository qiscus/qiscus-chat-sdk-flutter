import 'package:dio/dio.dart';
import 'package:qiscus_chat_sdk/src/features/message/message.dart';
import 'package:test/test.dart';

import '../../../utils.dart';

void main() {
  group('MessageRepository', () {
    Dio dio;
    MessageRepository repo;

    setUp(() {
      dio = MockDio();
      repo = MessageRepositoryImpl(dio);
    });

    test('getMessages', () async {});
  });
}
