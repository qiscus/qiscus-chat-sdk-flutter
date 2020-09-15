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
  final Option<IMap<String, dynamic>> extras;
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
      id: optionOf(json['email'] as String),
      name: optionOf(json['username'] as String),
      avatarUrl: optionOf(json['avatar_url'] as String),
      extras: optionOf(json['extras'] as Object).bind(decodeJson).map(imap),
    );
  }

  QUser toModel() => QUser(
        id: id.toNullable(),
        name: name.toNullable(),
        avatarUrl: avatarUrl.toNullable(),
        extras: extras.map((it) => it.toMap()).toNullable(),
      );
}
