import 'package:meta/meta.dart';

typedef Function0<R> = R Function();
typedef Function1<R, P1> = R Function(P1);
typedef Function2<R, P1, P2> = R Function(P1, P2);

mixin Eq<T> {
  static Function2<bool, T, T> isEq<T>(Eq _eq) =>
      (T m1, T m2) => _eq.eq(m1, m2);
  bool eq(T t1, T t2);
  bool neq(T t1, T t2) => !eq(t1, t2);
}
mixin EqMixin<T> {
  bool eq(T that);
  bool neq(T that) => !eq(that);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is T && runtimeType == other.runtimeType && eq(other);
}
enum Ordering { gt, lt, eq }
mixin Ord<T> {
  Ordering order(T t1, T t2);
}

mixin Functor<F, In> {
  F fmap(covariant F fa);
}
mixin Foldable<M, In> {
  Function2<Out, Function0<Out>, Function1<Out, In>> fold<Out>(M mInstance);
}

@sealed
class Option<T> {
  final T _value;
  const Option(this._value);
}

@sealed
class Some<T> extends Option<T> {
  Some(T value) : super(value);
}

@sealed
class None extends Option<void> {
  None(void value) : super(null);
}

mixin Jsonable<T> {
  Map<String, dynamic> toJson();
}
mixin Show<T> {
  String show();

  @override
  String toString() {
    return show();
  }
}

void show(Show s) {
  print(s.show());
}

class User with Jsonable<User>, Show<User>, EqMixin<User> {
  final String userId;
  const User(this.userId);

  @override
  Map<String, dynamic> toJson() {
    return {};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;

  @override
  String show() => 'User($userId)';

  @override
  bool eq(User that) {
    return userId == that.userId;
  }
}

class UserEq with Eq<User> {
  eq(u1, u2) => u1 == u2;
}

final userEq = UserEq();

void main() async {
  var user1 = const User('user-1');
  var user2 = const User('user-2');

  print(user1);
  show(user1);

  if (Eq.isEq(userEq)(user1, user2)) {
    print('they are the same user');
  } else {
    print('they are not the same user');
  }
}
