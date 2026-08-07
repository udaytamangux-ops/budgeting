import 'package:budgeting_app/core/calendar/data/bikram_sambat_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/features/summary/domain/entities/monthly_category_activity.dart';
import 'package:budgeting_app/features/summary/domain/entities/monthly_transaction_summary.dart';
import 'package:budgeting_app/features/summary/domain/services/category_activity_service.dart';
import 'package:budgeting_app/features/summary/domain/services/transaction_summary_service.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_list_filter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_data.dart';

void main() {
  final BikramSambatCalendarService calendarService =
      BikramSambatCalendarService();
  final CalendarPeriod shrawan = calendarService.periodFor(
    calendarSystem: AppCalendarSystem.bikramSambatBs,
    year: 2083,
    month: 4,
  );

  List<FinancialTransaction> transactions() => <FinancialTransaction>[
    buildTestTransaction(
      id: 'first-day-expense',
      minorUnits: 10000,
      occurredAt: DateTime.utc(2026, 7, 17, 12),
    ),
    buildTestTransaction(
      id: 'last-day-expense',
      minorUnits: 20000,
      occurredAt: DateTime.utc(2026, 8, 16, 12),
    ),
    buildTestTransaction(
      id: 'after-period-expense',
      minorUnits: 40000,
      occurredAt: DateTime.utc(2026, 8, 17, 12),
    ),
    buildTestTransaction(
      id: 'shrawan-income',
      type: TransactionType.income,
      category: TransactionCategory.salary,
      minorUnits: 90000,
      occurredAt: DateTime.utc(2026, 8, 1, 12),
    ),
  ];

  test('BS month filtering includes first and last day, not end boundary', () {
    final List<TransactionDateGroup> groups = const TransactionListFilter()
        .apply(transactions: transactions(), period: shrawan);
    final List<String> ids = groups
        .expand(
          (TransactionDateGroup group) =>
              group.transactions.map((FinancialTransaction value) => value.id),
        )
        .toList();

    expect(
      ids,
      containsAll(<String>[
        'first-day-expense',
        'last-day-expense',
        'shrawan-income',
      ]),
    );
    expect(ids, isNot(contains('after-period-expense')));
  });

  test('BS period combines month and type filters', () {
    final List<TransactionDateGroup> groups = const TransactionListFilter()
        .apply(
          transactions: transactions(),
          period: shrawan,
          type: TransactionType.expense,
          query: 'Food',
        );

    expect(
      groups.expand((TransactionDateGroup group) => group.transactions),
      hasLength(2),
    );
  });

  test('Summary and Category Details agree for the same BS period', () {
    final List<FinancialTransaction> values = transactions();
    final MonthlyTransactionSummary summary = const TransactionSummaryService()
        .calculateForPeriod(transactions: values, period: shrawan);
    final CategoryActivityDetails details = const CategoryActivityService()
        .calculateForCategoriesInPeriod(
          transactions: values,
          period: shrawan,
          type: TransactionType.expense,
          categories: const <TransactionCategory>[TransactionCategory.food],
        );

    expect(summary.expenses.minorUnits, 30000);
    expect(summary.income.minorUnits, 90000);
    expect(summary.transactionCount, 3);
    expect(details.total.minorUnits, 30000);
    expect(details.relevantMonthlyTotal, summary.expenses);
    expect(details.transactionCount, 2);
    expect(details.sharePercentage, 100);
  });
}
