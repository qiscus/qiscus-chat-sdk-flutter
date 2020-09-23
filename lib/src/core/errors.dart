part of qiscus_chat_sdk.core;

class QError extends Error with EquatableMixin {
  final String message;

  QError(this.message);

  @override
  String toString() {
    return 'QError: $message';
  }

  @override
  List<Object> get props => [message];

  @override
  bool get stringify => true;
}
