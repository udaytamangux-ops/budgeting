import 'package:budgeting_app/core/calendar/data/bikram_sambat_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/monthly_reports/domain/entities/monthly_report_data.dart';
import 'package:budgeting_app/features/monthly_reports/domain/services/monthly_report_service.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_data.dart';

void main() {
  final BikramSambatCalendarService calendar = BikramSambatCalendarService();
  late MonthlyReportService service;

  setUp(() {
    service = MonthlyReportService(calendar);
  });

  test('uses centralized effects for income, expense, transfer, and fee', () {
    final period = calendar.periodFor(
      calendarSystem: AppCalendarSystem.gregorianAd,
      year: 2026,
      month: 8,
    );
    final MonthlyReportData report = service.build(
      period: period,
      now: DateTime.utc(2026, 8, 20),
      activities: <FinancialActivity>[
        TransactionActivity(
          buildTestTransaction(
            id: 'income',
            type: TransactionType.income,
            category: TransactionCategory.salary,
            minorUnits: 1000000,
          ),
        ),
        TransactionActivity(
          buildTestTransaction(id: 'food', minorUnits: 200000),
        ),
        TransferActivity(buildTestTransfer(id: 'movement', minorUnits: 500000)),
        TransferActivity(
          buildTestTransfer(
            id: 'counted',
            minorUnits: 300000,
            countsAsExpense: true,
            expenseCategory: TransactionCategory.family,
            feeMinorUnits: 1000,
          ),
        ),
      ],
    );

    expect(report.incomeTotal.minorUnits, 1000000);
    expect(report.expenseTotal.minorUnits, 501000);
    expect(report.netChange.minorUnits, 499000);
    expect(report.activityCount, 4, reason: 'activities are counted once');
    expect(report.transferSummary.count, 2);
    expect(report.transferSummary.movementTotal.minorUnits, 800000);
    expect(report.transferSummary.countedAsExpenseTotal.minorUnits, 300000);
    expect(report.transferSummary.feeTotal.minorUnits, 1000);
    expect(
      report.expenseCategories
          .singleWhere((value) => value.category == TransactionCategory.family)
          .amount
          .minorUnits,
      300000,
    );
    expect(
      report.expenseCategories
          .singleWhere(
            (value) => value.category == TransactionCategory.feesAndCharges,
          )
          .amount
          .minorUnits,
      1000,
    );
    expect(
      report.expenseCategories.fold<int>(
        0,
        (sum, value) => sum + value.basisPoints,
      ),
      10000,
    );
  });

  test('excludes normal transfer from income and expense categories', () {
    final period = calendar.periodFor(
      calendarSystem: AppCalendarSystem.gregorianAd,
      year: 2026,
      month: 8,
    );
    final MonthlyReportData report = service.build(
      period: period,
      now: DateTime.utc(2026, 8, 20),
      activities: <FinancialActivity>[TransferActivity(buildTestTransfer())],
    );

    expect(report.incomeTotal.isZero, isTrue);
    expect(report.expenseTotal.isZero, isTrue);
    expect(report.expenseCategories, isEmpty);
    expect(report.activityCount, 1);
    expect(report.transferSummary.movementTotal.minorUnits, 500000);
  });

  test('current period compares equal elapsed portions of both months', () {
    final period = calendar.periodFor(
      calendarSystem: AppCalendarSystem.gregorianAd,
      year: 2026,
      month: 8,
    );
    final comparison = service.compare(
      selectedPeriod: period,
      now: DateTime.utc(2026, 8, 4),
      activities: <FinancialActivity>[
        TransactionActivity(
          buildTestTransaction(
            id: 'current-included',
            minorUnits: 20000,
            occurredAt: DateTime.utc(2026, 8, 4),
          ),
        ),
        TransactionActivity(
          buildTestTransaction(
            id: 'current-future',
            minorUnits: 90000,
            occurredAt: DateTime.utc(2026, 8, 20),
          ),
        ),
        TransactionActivity(
          buildTestTransaction(
            id: 'prior-included',
            minorUnits: 10000,
            occurredAt: DateTime.utc(2026, 7, 4),
          ),
        ),
        TransactionActivity(
          buildTestTransaction(
            id: 'prior-later',
            minorUnits: 80000,
            occurredAt: DateTime.utc(2026, 7, 20),
          ),
        ),
      ],
    );

    expect(comparison.isPartialComparison, isTrue);
    expect(comparison.expenses.current.minorUnits, 20000);
    expect(comparison.expenses.previous.minorUnits, 10000);
    expect(comparison.previousActivityCount, 1);
    expect(comparison.expenses.changeBasisPoints, 10000);
  });

  test('BS report uses actual BS period boundaries', () {
    final period = calendar.periodFor(
      calendarSystem: AppCalendarSystem.bikramSambatBs,
      year: 2083,
      month: 4,
    );
    final MonthlyReportData report = service.build(
      period: period,
      now: period.endAdExclusive.subtract(const Duration(days: 1)),
      activities: <FinancialActivity>[
        TransactionActivity(
          buildTestTransaction(
            id: 'first',
            occurredAt: period.startAdInclusive,
          ),
        ),
        TransactionActivity(
          buildTestTransaction(
            id: 'outside',
            occurredAt: period.endAdExclusive,
          ),
        ),
      ],
    );

    expect(report.activities.map((value) => value.id), <String>['first']);
  });

  test('completed month comparison uses both complete periods', () {
    final period = calendar.periodFor(
      calendarSystem: AppCalendarSystem.gregorianAd,
      year: 2026,
      month: 7,
    );
    final comparison = service.compare(
      selectedPeriod: period,
      now: DateTime.utc(2026, 8, 4),
      activities: <FinancialActivity>[
        TransactionActivity(
          buildTestTransaction(
            id: 'july-last-day',
            minorUnits: 30000,
            occurredAt: DateTime.utc(2026, 7, 31),
          ),
        ),
        TransactionActivity(
          buildTestTransaction(
            id: 'june-last-day',
            minorUnits: 10000,
            occurredAt: DateTime.utc(2026, 6, 30),
          ),
        ),
      ],
    );

    expect(comparison.isPartialComparison, isFalse);
    expect(comparison.expenses.current.minorUnits, 30000);
    expect(comparison.expenses.previous.minorUnits, 10000);
    expect(comparison.explanation, contains('previous month'));
  });

  test('zero previous data avoids division and positive claims', () {
    final period = calendar.periodFor(
      calendarSystem: AppCalendarSystem.gregorianAd,
      year: 2026,
      month: 8,
    );
    final comparison = service.compare(
      selectedPeriod: period,
      now: DateTime.utc(2026, 8, 4),
      activities: <FinancialActivity>[
        TransactionActivity(buildTestTransaction(id: 'only-current')),
      ],
    );

    expect(comparison.expenses.changeBasisPoints, isNull);
    expect(comparison.hasComparableData, isFalse);
    expect(comparison.hasPositiveFactualMessage, isFalse);
    expect(comparison.explanation, contains('Not enough recorded activity'));
  });

  test('visual-only Other aggregation preserves exact underlying totals', () {
    final period = calendar.periodFor(
      calendarSystem: AppCalendarSystem.gregorianAd,
      year: 2026,
      month: 8,
    );
    final List<TransactionCategory> categories = <TransactionCategory>[
      TransactionCategory.food,
      TransactionCategory.transport,
      TransactionCategory.rentAndHousing,
      TransactionCategory.utilities,
      TransactionCategory.shopping,
      TransactionCategory.health,
    ];
    final MonthlyReportData report = service.build(
      period: period,
      now: DateTime.utc(2026, 8, 20),
      activities: <FinancialActivity>[
        for (int index = 0; index < categories.length; index += 1)
          TransactionActivity(
            buildTestTransaction(
              id: 'category-$index',
              category: categories[index],
              minorUnits: (categories.length - index) * 10000,
            ),
          ),
      ],
    );

    expect(report.expenseCategories, hasLength(6));
    expect(report.expenseChart, hasLength(5));
    expect(report.expenseChart.last.label, 'Other');
    expect(
      report.expenseChart.fold<int>(
        0,
        (sum, value) => sum + value.amount.minorUnits,
      ),
      report.expenseTotal.minorUnits,
    );
    expect(
      report.expenseChart.fold<int>(0, (sum, value) => sum + value.basisPoints),
      10000,
    );
  });
}
