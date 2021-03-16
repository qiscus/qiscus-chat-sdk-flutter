part of qiscus_chat_sdk.usecase.user;

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

  @override
  String toString() => 'QUser('
      'id=$id, '
      'name=$name, '
      'avatarUrl=$avatarUrl, '
      'extras=$extras'
      ')';
}

class User {
  final Option<String> id, name, avatarUrl;
  final Option<Map<String, dynamic>> extras;
  User._({
    @required this.id,
    this.name,
    this.avatarUrl,
    this.extras,
  });
  factory User({
    Option<String> id,
    Option<String> name,
    Option<String> avatarUrl,
    Option<Map<String, dynamic>> extras,
  }) {
    return User._(
      id: id,
      name: name ?? Option.none(),
      avatarUrl: avatarUrl ?? Option.none(),
      extras: extras ?? Option.none(),
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: Option.of(json['email'] as String),
      name: Option.of(json['username'] as String),
      avatarUrl: Option.of(json['avatar_url'] as String),
      extras: Option.of(json['extras'] as Object).flatMap(decodeJson),
    );
  }

  QUser toModel() {
    return QUser(
        id: id.toNullable(),
        name: name.toNullable(),
        avatarUrl: avatarUrl.toNullable(),
        extras: extras.toNullable(),
      );
  }
}
