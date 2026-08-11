import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/financial_activity/domain/services/financial_effect_service.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/monthly_financial_summary.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transfers/domain/entities/financial_transfer.dart';

final class FinancialSummaryService {
  const FinancialSummaryService();

  MonthlyFinancialSummary calculateForMonth({
    required List<FinancialTransaction> transactions,
    required DateTime month,
    List<FinancialTransfer> transfers = const <FinancialTransfer>[],
  }) {
    return calculateForPeriod(
      transactions: transactions,
      transfers: transfers,
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
    List<FinancialTransfer> transfers = const <FinancialTransfer>[],
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

    const FinancialEffectService effects = FinancialEffectService();
    for (final FinancialTransfer transfer in transfers) {
      if (!period.contains(transfer.occurredAt)) continue;
      final FinancialEffect effect = effects.forTransfer(transfer);
      income += effect.incomeImpact;
      expenses += effect.expenseImpact;
    }

    return MonthlyFinancialSummary(
      month: period.startAdInclusive,
      income: income,
      expenses: expenses,
    );
  }

  Money closingRecordedBalanceThrough({
    required List<FinancialActivity> activities,
    required DateTime endAdExclusive,
  }) {
    Money balance = const Money.zero();
    const FinancialEffectService effects = FinancialEffectService();
    for (final FinancialActivity activity in activities) {
      if (!activity.occurredAt.isBefore(endAdExclusive)) continue;
      final FinancialEffect effect = effects.forActivity(activity);
      balance += effect.incomeImpact;
      balance -= effect.expenseImpact;
    }
    return balance;
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
