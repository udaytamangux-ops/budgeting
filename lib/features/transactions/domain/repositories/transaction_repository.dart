import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';

abstract interface class TransactionRepository {
  Stream<List<FinancialTransaction>> watchTransactions();

  Future<FinancialTransaction?> getTransactionById(String transactionId);

  Future<void> createTransaction(FinancialTransaction transaction);

  Future<void> updateTransaction(FinancialTransaction transaction);

  Future<void> deleteTransaction(String transactionId);
}
