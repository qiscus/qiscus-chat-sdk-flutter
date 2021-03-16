part of qiscus_chat_sdk.core;

class MError with EquatableMixin implements Error {
  final String message;
  @override
  final StackTrace stackTrace;

  MError(this.message, [this.stackTrace]);

  @override
  List<Object> get props => [message];

  @override
  bool get stringify => true;
}

class QError with EquatableMixin implements Error {
  final String message;
  @override
  final StackTrace stackTrace;

  QError(this.message, [this.stackTrace]);

  @override
  List<Object> get props => [message];
  @override
  bool get stringify => true;
}
