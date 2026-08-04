import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/monthly_financial_summary.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

final class FinancialSummaryService {
  const FinancialSummaryService();

  MonthlyFinancialSummary calculateForMonth({
    required List<FinancialTransaction> transactions,
    required DateTime month,
  }) {
    Money income = const Money.zero();
    Money expenses = const Money.zero();

    for (final FinancialTransaction transaction in transactions) {
      if (!_isInLocalMonth(transaction.occurredAt, month)) {
        continue;
      }

      switch (transaction.type) {
        case TransactionType.income:
          income += transaction.amount;
        case TransactionType.expense:
          expenses += transaction.amount;
      }
    }

    return MonthlyFinancialSummary(
      month: DateTime(month.year, month.month),
      income: income,
      expenses: expenses,
    );
  }

  List<FinancialTransaction> sortNewestFirst(
    Iterable<FinancialTransaction> transactions,
  ) {
    final List<FinancialTransaction> sorted = transactions.toList();
    sorted.sort((FinancialTransaction first, FinancialTransaction second) {
      final int occurredComparison = second.occurredAt.compareTo(
        first.occurredAt,
      );
      if (occurredComparison != 0) {
        return occurredComparison;
      }
      return second.createdAt.compareTo(first.createdAt);
    });
    return List<FinancialTransaction>.unmodifiable(sorted);
  }

  bool _isInLocalMonth(DateTime timestamp, DateTime month) {
    final DateTime localTimestamp = timestamp.toLocal();
    return localTimestamp.year == month.year &&
        localTimestamp.month == month.month;
  }
}
