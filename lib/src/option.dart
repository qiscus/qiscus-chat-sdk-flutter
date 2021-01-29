import 'package:meta/meta.dart';
import 'package:sealed_unions/sealed_unions.dart';

Doublet<Some<T>, None> _factory<T>() => Doublet<Some<T>, None>();

class Option<T> extends Union2Impl<Some<T>, None> {
  Option._(Union2<Some<T>, None> union) : super(union);
  factory Option.of(T value) =>
      value == null ? Option.none() : Option.some(value);
  factory Option.some(T value) => Option._(_factory<T>().first(Some._(value)));
  factory Option.none() => Option._(_factory<T>().second(None._()));

  @override
  String toString() {
    return join(
      (some) => 'Some(${some.value})',
      (_) => 'None',
    );
  }

  Option<I> map<I>(I Function(T) mapper) {
    return join(
      (some) => Option.of(mapper(some.value)),
      (_) => Option.none(),
    );
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
