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

final class TransferRepositoryException extends AppException {
  const TransferRepositoryException(super.message, {super.cause});
}

final class TransferNotFoundException extends AppException {
  const TransferNotFoundException(String transferId)
    : super('Transfer $transferId was not found.');
}

final class RecurringRepositoryException extends AppException {
  const RecurringRepositoryException(super.message, {super.cause});
}
