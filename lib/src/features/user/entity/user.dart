import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:qiscus_chat_sdk/src/core/extension.dart';

@immutable
class QUser {
  final String id, name, avatarUrl;
  final Map<String, dynamic> extras;

  QUser({
    @required this.id,
    this.name,
    this.avatarUrl,
    this.extras,
  });
}

class User {
  final String id;
  final Option<String> name, avatarUrl;
  final Option<IMap<String, dynamic>> extras;
  User._({
    @required this.id,
    this.name,
    this.avatarUrl,
    this.extras,
  });
  factory User({
    String id,
    Option<String> name,
    Option<String> avatarUrl,
    Option<IMap<String, dynamic>> extras,
  }) {
    return User._(
      id: id,
      name: name ?? none(),
      avatarUrl: avatarUrl ?? none(),
      extras: extras ?? none(),
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['email'] as String,
      name: optionOf(json['username'] as String),
      avatarUrl: optionOf(json['avatar_url'] as String),
      extras: optionOf(json['extras'] as Map<String, dynamic>).map(imap),
    );
  }

  QUser toModel() => QUser(
        id: id,
        name: name.toNullable(),
        avatarUrl: avatarUrl.toNullable(),
        extras: extras.map((it) => it.toMap()).toNullable(),
      );
}
