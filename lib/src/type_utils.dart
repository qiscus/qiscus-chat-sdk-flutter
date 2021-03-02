import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:sealed_unions/sealed_unions.dart';

@sealed
class Right<R> with EquatableMixin {
  const Right._(this.value);

  final R value;

  get props => [value];
  @override
  String toString() => 'Right($value)';
}

@sealed
class Left<L> with EquatableMixin {
  const Left._(this.value);

  final L value;

  get props => [value];

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
class Some<T> with EquatableMixin {
  const Some._(this.value);

  final T value;

  get props => [value];
}

@sealed
class None with EquatableMixin {
  const None._();

  get props => [];
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
