import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
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
    return calculateForPeriod(
      transactions: transactions,
      period: CalendarPeriod(
        calendarSystem: AppCalendarSystem.gregorianAd,
        year: month.year,
        month: month.month,
        startAdInclusive: DateTime.utc(month.year, month.month),
        endAdExclusive: DateTime.utc(month.year, month.month + 1),
        displayLabel: '',
      ),
    );
  }

  MonthlyTransactionSummary calculateForPeriod({
    required List<FinancialTransaction> transactions,
    required CalendarPeriod period,
  }) {
    final MonthlyFinancialSummary financialSummary =
        const FinancialSummaryService().calculateForPeriod(
          transactions: transactions,
          period: period,
        );
    final MonthlyCategoryActivity expenseActivity =
        const CategoryActivityService().calculateForPeriod(
          transactions: transactions,
          period: period,
          type: TransactionType.expense,
        );
    final Map<PaymentMethod, int> paymentMethodCounts = <PaymentMethod, int>{};
    int transactionCount = 0;

    for (final FinancialTransaction transaction in transactions) {
      if (!period.contains(transaction.occurredAt)) {
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
}
