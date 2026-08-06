import 'package:budgeting_app/features/summary/domain/entities/monthly_category_activity.dart';
import 'package:budgeting_app/features/summary/domain/entities/monthly_transaction_summary.dart';
import 'package:budgeting_app/features/summary/domain/services/category_activity_service.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/monthly_financial_summary.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/domain/services/financial_summary_service.dart';

final class TransactionSummaryService {
  const TransactionSummaryService();

  MonthlyTransactionSummary calculateForMonth({
    required List<FinancialTransaction> transactions,
    required DateTime month,
  }) {
    final MonthlyFinancialSummary financialSummary =
        const FinancialSummaryService().calculateForMonth(
          transactions: transactions,
          month: month,
        );
    final MonthlyCategoryActivity expenseActivity =
        const CategoryActivityService().calculateForMonth(
          transactions: transactions,
          month: month,
          type: TransactionType.expense,
        );
    final Map<PaymentMethod, int> paymentMethodCounts = <PaymentMethod, int>{};
    int transactionCount = 0;

    for (final FinancialTransaction transaction in transactions) {
      if (!_isInLocalMonth(transaction.occurredAt, month)) {
        continue;
      }
      transactionCount += 1;
      paymentMethodCounts.update(
        transaction.paymentMethod,
        (int count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    final List<CategorySpendingRecord> categoryRecords = expenseActivity.records
        .map(
          (CategoryActivityRecord record) => CategorySpendingRecord(
            category: record.category,
            amount: record.amount,
            sharePercentage: record.sharePercentage,
          ),
        )
        .toList(growable: false);
    final List<CategorySpendingGroup> spendingGroups = expenseActivity.groups
        .map(
          (CategoryActivityGroup group) => CategorySpendingGroup(
            category: group.category,
            includedCategories: group.includedCategories,
            amount: group.amount,
            sharePercentage: group.sharePercentage,
          ),
        )
        .toList(growable: false);

    final List<PaymentMethodUsageRecord> paymentRecords =
        paymentMethodCounts.entries
            .map(
              (MapEntry<PaymentMethod, int> entry) => PaymentMethodUsageRecord(
                paymentMethod: entry.key,
                transactionCount: entry.value,
                sharePercentage: _percentage(entry.value, transactionCount),
              ),
            )
            .toList()
          ..sort((
            PaymentMethodUsageRecord first,
            PaymentMethodUsageRecord second,
          ) {
            final int countComparison = second.transactionCount.compareTo(
              first.transactionCount,
            );
            return countComparison != 0
                ? countComparison
                : first.paymentMethod.index.compareTo(
                    second.paymentMethod.index,
                  );
          });

    return MonthlyTransactionSummary(
      financialSummary: financialSummary,
      transactionCount: transactionCount,
      categorySpending: List<CategorySpendingRecord>.unmodifiable(
        categoryRecords,
      ),
      spendingGroups: spendingGroups,
      paymentMethods: List<PaymentMethodUsageRecord>.unmodifiable(
        paymentRecords,
      ),
    );
  }

  int _percentage(int part, int total) {
    if (part <= 0 || total <= 0) {
      return 0;
    }
    return (part * 100 + total ~/ 2) ~/ total;
  }

  bool _isInLocalMonth(DateTime timestamp, DateTime month) {
    final DateTime localTimestamp = timestamp.toLocal();
    return localTimestamp.year == month.year &&
        localTimestamp.month == month.month;
  }
}
