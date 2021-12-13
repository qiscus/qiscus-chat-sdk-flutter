part of qiscus_chat_sdk.core;

class QError with EquatableMixin implements Error {
  final String message;
  final StackTrace? stackTrace;

  QError(this.message, [this.stackTrace]);

  @override
  List<Object> get props => [message];
  @override
  bool get stringify => true;
}

class QRawError {
  /// An readable human error message
  final String message;

  /// Raw error message from error object
  final String rawMessage;

  const QRawError(this.message, this.rawMessage);
}
