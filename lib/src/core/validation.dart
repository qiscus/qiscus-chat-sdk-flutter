import 'package:dartz/dartz.dart';

Either<Error, O> validateNotNull<O>(O any) {
  if (any == null) return left(ArgumentError('$any should not be null'));
  return right(any);
}

Either<Error, String> validateString(Object str) {
  if (str.runtimeType == String) {
    return right(str as String);
  }
  return left(ArgumentError('$str is not a string'));
}

Either<Error, String> validateUserId(String userId) {
  var mValidator = monoid<String>(() => '', (a, b) => a + b);

  var a = validateNotNull(userId);
  var b = validateString(userId);
}
