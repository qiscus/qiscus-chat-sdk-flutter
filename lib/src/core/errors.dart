class QError extends Error {
  final String message;

  QError(this.message);

  @override
  String toString() {
    return 'QError($message)';
  }
}
