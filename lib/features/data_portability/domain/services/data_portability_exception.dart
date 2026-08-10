final class DataPortabilityException implements Exception {
  const DataPortabilityException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}
