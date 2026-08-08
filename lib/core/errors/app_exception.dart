sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

final class TransactionRepositoryException extends AppException {
  const TransactionRepositoryException(super.message, {super.cause});
}

final class TransactionNotFoundException extends AppException {
  const TransactionNotFoundException(String transactionId)
    : super('Transaction $transactionId was not found.');
}

final class RecurringRepositoryException extends AppException {
  const RecurringRepositoryException(super.message, {super.cause});
}
