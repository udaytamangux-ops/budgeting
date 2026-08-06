import 'package:budgeting_app/core/database/app_database.dart';
import 'package:budgeting_app/core/errors/app_exception.dart';
import 'package:budgeting_app/features/transactions/data/database/transaction_database_mapper.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:budgeting_app/features/transactions/domain/services/financial_summary_service.dart';

final class DriftTransactionRepository implements TransactionRepository {
  const DriftTransactionRepository(this._database);

  final AppDatabase _database;
  static const FinancialSummaryService _summaryService =
      FinancialSummaryService();

  @override
  Stream<List<FinancialTransaction>> watchTransactions() {
    return _database.watchAllStoredTransactions().map((rows) {
      final List<FinancialTransaction> transactions = rows
          .map(TransactionDatabaseMapper.fromRow)
          .toList(growable: false);
      return _summaryService.sortNewestFirst(transactions);
    });
  }

  @override
  Future<FinancialTransaction?> getTransactionById(String transactionId) async {
    try {
      final StoredTransaction? row = await _database.findStoredTransaction(
        transactionId,
      );
      return row == null ? null : TransactionDatabaseMapper.fromRow(row);
    } catch (error) {
      throw TransactionRepositoryException(
        'The transaction could not be loaded. Try again.',
        cause: error,
      );
    }
  }

  @override
  Future<void> createTransaction(FinancialTransaction transaction) async {
    try {
      if (await _database.findStoredTransaction(transaction.id) != null) {
        throw const TransactionRepositoryException(
          'This transaction has already been saved.',
        );
      }
      await _database.insertStoredTransaction(
        TransactionDatabaseMapper.toCompanion(transaction),
      );
    } on AppException {
      rethrow;
    } catch (error) {
      throw TransactionRepositoryException(
        'The transaction could not be saved. Try again.',
        cause: error,
      );
    }
  }

  @override
  Future<void> updateTransaction(FinancialTransaction transaction) async {
    try {
      final int updated = await _database.updateStoredTransaction(
        transaction.id,
        TransactionDatabaseMapper.toCompanion(transaction),
      );
      if (updated == 0) {
        throw TransactionNotFoundException(transaction.id);
      }
    } on AppException {
      rethrow;
    } catch (error) {
      throw TransactionRepositoryException(
        'The transaction could not be updated. Try again.',
        cause: error,
      );
    }
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    try {
      final int deleted = await _database.deleteStoredTransaction(
        transactionId,
      );
      if (deleted == 0) {
        throw TransactionNotFoundException(transactionId);
      }
    } on AppException {
      rethrow;
    } catch (error) {
      throw TransactionRepositoryException(
        'The transaction could not be deleted. Try again.',
        cause: error,
      );
    }
  }
}
