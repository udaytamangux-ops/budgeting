import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
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

  MonthlyFinancialSummary calculateForPeriod({
    required List<FinancialTransaction> transactions,
    required CalendarPeriod period,
  }) {
    Money income = const Money.zero();
    Money expenses = const Money.zero();

    for (final FinancialTransaction transaction in transactions) {
      if (!period.contains(transaction.occurredAt)) {
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
      month: period.startAdInclusive,
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
}
