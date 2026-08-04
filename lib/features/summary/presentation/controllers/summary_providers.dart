import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/features/summary/domain/entities/monthly_transaction_summary.dart';
import 'package:budgeting_app/features/summary/domain/services/transaction_summary_service.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ProviderFamily<AsyncValue<MonthlyTransactionSummary>, DateTime>
monthlyTransactionSummaryForMonthProvider =
    Provider.family<AsyncValue<MonthlyTransactionSummary>, DateTime>((
      Ref ref,
      DateTime month,
    ) {
      final AsyncValue<List<FinancialTransaction>> transactions = ref.watch(
        transactionListProvider,
      );
      return transactions.whenData(
        (List<FinancialTransaction> value) => const TransactionSummaryService()
            .calculateForMonth(transactions: value, month: month),
      );
    });

final Provider<AsyncValue<MonthlyTransactionSummary>>
currentMonthlyTransactionSummaryProvider =
    Provider<AsyncValue<MonthlyTransactionSummary>>((Ref ref) {
      final DateTime currentDate = ref.watch(currentDateProvider);
      return ref.watch(
        monthlyTransactionSummaryForMonthProvider(
          DateTime(currentDate.year, currentDate.month),
        ),
      );
    });
