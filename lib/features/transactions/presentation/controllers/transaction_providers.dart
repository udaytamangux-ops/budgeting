import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/features/budgets/domain/entities/monthly_budget_summary.dart';
import 'package:budgeting_app/features/budgets/domain/services/budget_summary_service.dart';
import 'package:budgeting_app/features/transactions/data/repositories/in_memory_transaction_repository.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/monthly_financial_summary.dart';
import 'package:budgeting_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:budgeting_app/features/transactions/domain/services/financial_summary_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<TransactionRepository> transactionRepositoryProvider =
    Provider<TransactionRepository>((Ref ref) {
      final InMemoryTransactionRepository repository =
          InMemoryTransactionRepository(now: ref.watch(appClockProvider));
      ref.onDispose(repository.dispose);
      return repository;
    });

final StreamProvider<List<FinancialTransaction>> transactionListProvider =
    StreamProvider<List<FinancialTransaction>>((Ref ref) {
      return ref.watch(transactionRepositoryProvider).watchTransactions();
    });

final Provider<AsyncValue<MonthlyFinancialSummary>>
monthlyFinancialSummaryProvider = Provider<AsyncValue<MonthlyFinancialSummary>>(
  (Ref ref) {
    final AsyncValue<List<FinancialTransaction>> transactions = ref.watch(
      transactionListProvider,
    );
    final DateTime currentDate = ref.watch(currentDateProvider);
    return transactions.whenData(
      (List<FinancialTransaction> value) => const FinancialSummaryService()
          .calculateForMonth(transactions: value, month: currentDate),
    );
  },
);

final Provider<AsyncValue<MonthlyBudgetSummary>> monthlyBudgetSummaryProvider =
    Provider<AsyncValue<MonthlyBudgetSummary>>((Ref ref) {
      final AsyncValue<List<FinancialTransaction>> transactions = ref.watch(
        transactionListProvider,
      );
      final DateTime currentDate = ref.watch(currentDateProvider);
      return transactions.whenData(
        (List<FinancialTransaction> value) => const BudgetSummaryService()
            .calculateForMonth(transactions: value, month: currentDate),
      );
    });

final ProviderFamily<AsyncValue<FinancialTransaction?>, String>
transactionByIdProvider =
    Provider.family<AsyncValue<FinancialTransaction?>, String>((
      Ref ref,
      String id,
    ) {
      return ref.watch(transactionListProvider).whenData((
        List<FinancialTransaction> transactions,
      ) {
        for (final FinancialTransaction transaction in transactions) {
          if (transaction.id == id) {
            return transaction;
          }
        }
        return null;
      });
    });
