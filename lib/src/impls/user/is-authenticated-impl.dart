import 'package:fpdart/fpdart.dart';
import 'package:qiscus_chat_sdk/src/core.dart';

Reader<Storage, bool> isAuthenticatedImpl = Reader((Storage s) {
  return s.currentUser != null;
});

Reader<Storage, Task<bool>> waitTillAuthenticatedImpl() {
  return Reader((Storage s) {
    return Task(() async {
      return Stream.periodic(
        const Duration(milliseconds: 300),
        (_) => s.token != null,
      ).firstWhere((it) => it == true);
    });
  });
}
