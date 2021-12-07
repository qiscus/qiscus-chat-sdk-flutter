
import 'package:fpdart/fpdart.dart';

abstract class ForIOReader {}

class IOReader<R, O> extends HKT2<ForIOReader, R, O>
with Monad2<ForIOReader, R, O> {
  final O Function(R r) _run;

  IOReader(this._run);

  @override
  IOReader<R, C> flatMap<C>(covariant IOReader<R, C> Function(O a) f) {
    throw UnimplementedError();
  }

  @override
  IOReader<R, C> pure<C>(C a) {
    return IOReader((_) => a);
  }

  IOReader<R, O1> call<O1>(covariant IOReader<R, O1> reader) {
    return flatMap((_) => reader);
  }

  O run(R r) {
    return _run(r);
  }
}


void mm() {
  var ior = IOReader((String name) {
    print('your name are: $name');
    return name.length;
  });

  var res = ior.call(IOReader((haha) => '${haha.length}'));
  var out = res.run('Afief s');
}
