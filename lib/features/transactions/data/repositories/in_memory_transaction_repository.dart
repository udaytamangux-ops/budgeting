import 'dart:async';

import 'package:budgeting_app/core/errors/app_exception.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:budgeting_app/features/transactions/domain/services/financial_summary_service.dart';

final class InMemoryTransactionRepository implements TransactionRepository {
  InMemoryTransactionRepository({
    List<FinancialTransaction>? seedTransactions,
    Duration operationDelay = const Duration(milliseconds: 320),
    DateTime Function()? now,
  }) : _saveDelay = operationDelay,
       _now = now ?? DateTime.now,
       _transactions = List<FinancialTransaction>.from(
         seedTransactions ?? const <FinancialTransaction>[],
       );

  final Duration _saveDelay;
  final DateTime Function() _now;
  final List<FinancialTransaction> _transactions;
  final StreamController<List<FinancialTransaction>> _changes =
      StreamController<List<FinancialTransaction>>.broadcast(sync: true);
  final FinancialSummaryService _summaryService =
      const FinancialSummaryService();

  bool _shouldFailNextCreate = false;
  bool _shouldFailNextDelete = false;

  void simulateNextCreateFailure() {
    _shouldFailNextCreate = true;
  }

  void simulateNextDeleteFailure() {
    _shouldFailNextDelete = true;
  }

  @override
  Stream<List<FinancialTransaction>> watchTransactions() async* {
    yield _snapshot();
    yield* _changes.stream;
  }

  @override
  Future<FinancialTransaction?> getTransactionById(String transactionId) async {
    for (final FinancialTransaction transaction in _transactions) {
      if (transaction.id == transactionId) {
        return transaction;
      }
    }
    return null;
  }

  @override
  Future<void> createTransaction(FinancialTransaction transaction) async {
    await Future<void>.delayed(_saveDelay);

    if (_shouldFailNextCreate) {
      _shouldFailNextCreate = false;
      throw const TransactionRepositoryException(
        'The transaction could not be saved. Try again.',
      );
    }

    final bool alreadyExists = _transactions.any(
      (FinancialTransaction existing) => existing.id == transaction.id,
    );
    if (alreadyExists) {
      throw const TransactionRepositoryException(
        'This transaction has already been saved.',
      );
    }

    _transactions.add(transaction);
    _emit();
  }

  @override
  Future<void> updateTransaction(FinancialTransaction transaction) async {
    await Future<void>.delayed(_saveDelay);
    final int index = _transactions.indexWhere(
      (FinancialTransaction existing) => existing.id == transaction.id,
    );
    if (index == -1) {
      throw TransactionNotFoundException(transaction.id);
    }
    _transactions[index] = transaction;
    _emit();
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    await Future<void>.delayed(_saveDelay);

    if (_shouldFailNextDelete) {
      _shouldFailNextDelete = false;
      throw const TransactionRepositoryException(
        'The transaction could not be deleted. Try again.',
      );
    }

    final int removedCount = _transactions.length;
    _transactions.removeWhere(
      (FinancialTransaction transaction) => transaction.id == transactionId,
    );
    if (_transactions.length == removedCount) {
      throw TransactionNotFoundException(transactionId);
    }
    _emit();
  }

  void dispose() {
    unawaited(_changes.close());
  }

  List<FinancialTransaction> _snapshot() {
    return _summaryService.sortNewestFirst(_transactions);
  }

  void _emit() {
    if (!_changes.isClosed) {
      _changes.add(_snapshot());
    }
  }

  DateTime get currentTime => _now().toUtc();
}
