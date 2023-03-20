part of qiscus_chat_sdk.core;

Option<Map<String, Object?>> decodeJson(Object? json) {
  return Option.fromNullable(json).flatMap((it) {
    if (it is Map && it.isEmpty) return Option.none();
    if (it is Map && it.isNotEmpty) {
      return Option.of(it as Json);
    }
    if (it is String && it.isEmpty) return Option.none();
    if (it is String && it.isNotEmpty) {
      try {
        var opts = jsonDecode(it) as Json;
        return Option.of(opts);
      } catch (error) {
        return Option.none();
      }
    }
    return Option.none();
  });
}
