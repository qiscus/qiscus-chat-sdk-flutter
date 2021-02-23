import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:sealed_unions/sealed_unions.dart';

class Either<L extends Error, R extends Object>
    extends Union2Impl<Left<L>, Right<R>> {
  static Doublet<Left<L>, Right<R>> _eitherFactory<L, R>() =>
      Doublet<Left<L>, Right<R>>();

  Either._(Union2<Left<L>, Right<R>> union) : super(union);

  factory Either.tryCatch(R Function() fn) {
    try {
      return Either.right(fn());
    } catch (err) {
      return Either.left(err as L);
    }
  }

  factory Either.left(L left) =>
      Either._(_eitherFactory<L, R>().first(Left._(left)));

  factory Either.right(R right) =>
      Either._(_eitherFactory<L, R>().second(Right._(right)));

  @override
  String toString() {
    return join((l) => l.toString(), (r) => r.toString());
  }

  Either<L, RO> map<RO>(RO Function(R) mapper) {
    return fold(
      (l) => Either.left(l),
      (r) => Either.right(mapper(r)),
    );
  }

  Either<L, RO> flatMap<RO>(Either<L, RO> Function(R) mapper) {
    return fold(
      (l) => Either.left(l),
      (r) => mapper(r),
    );
  }

  O fold<O>(O Function(L) onLeft, O Function(R) onRight) {
    return join(
      (l) => onLeft(l.value),
      (r) => onRight(r.value),
    );
  }

  Future<R> toFuture() {
    return fold(
      (l) => Future<R>.error(l),
      (r) => Future.value(r),
    );
  }
}

extension EitherX<L extends Error, R extends Object> on Either<L, R> {
  Option<R> toOption() {
    return join(
      (_) => Option.none(),
      (r) => Option.some(r.value),
    );
  }

  void toCallback1(void Function(L) cb) {
    continued(
      (l) => cb(l.value),
      (_) => cb(null),
    );
  }

  void toCallback2(void Function(R, L) cb) {
    continued(
      (l) => cb(null, l.value),
      (r) => cb(r.value, null),
    );
  }
}

@sealed
class Right<R> {
  const Right._(this.value);

  final R value;

  @override
  String toString() => 'Right($value)';
}

@sealed
class Left<L> {
  const Left._(this.value);

  final L value;

  @override
  String toString() => 'Left($value)';
}

class Option<T extends Object> extends Union2Impl<Some<T>, None> {
  static Doublet<Some<T>, None> _optionFactory<T>() => Doublet<Some<T>, None>();

  Option._(Union2<Some<T>, None> union) : super(union);

  factory Option.of(T value) =>
      value == null ? Option.none() : Option.some(value);

  factory Option.some(T value) =>
      Option._(_optionFactory<T>().first(Some._(value)));

  factory Option.none() => Option._(_optionFactory<T>().second(None._()));

  @override
  String toString() {
    return join(
      (some) => 'Some(${some.value})',
      (_) => 'None',
    );
  }

  Option<O> flatMap<O>(Option<O> Function(T) mapper) {
    return join(
      (some) => mapper(some.value),
      (_) => Option.none(),
    );
  }

  Option<I> map<I>(I Function(T) mapper) {
    return join(
      (some) => Option.of(mapper(some.value)),
      (_) => Option.none(),
    );
  }

  T getOrElse(T Function() orElse) {
    return join(
      (some) => some.value,
      (_) => orElse(),
    );
  }

  O fold<O>(O Function() onNone, O Function(T) onSome) {
    return join((s) => onSome(s.value), (_) => onNone());
  }

  T toNullable() {
    return getOrElse(() => null);
  }
}

@sealed
class Some<T> {
  const Some._(this.value);

  final T value;
}

@sealed
class None {
  const None._();
}

class Tuple2<T1, T2> with EquatableMixin {
  const Tuple2(this.first, this.second);

  final T1 first;
  final T2 second;

  @override
  List<Object> get props => [first, second];

  @override
  String toString() {
    // TODO: implement toString
    return ('Tuple2('
        'first=$first,'
        ' second=$second'
        ')');
  }
}
