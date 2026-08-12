import 'package:budgeting_app/core/calendar/data/bikram_sambat_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/monthly_reports/data/services/monthly_report_pdf_text_formatter.dart';
import 'package:budgeting_app/features/monthly_reports/domain/services/monthly_report_service.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_data.dart';

void main() {
  final BikramSambatCalendarService calendar = BikramSambatCalendarService();
  final MonthlyReportService reportService = MonthlyReportService(calendar);
  final MonthlyReportPdfTextFormatter formatter =
      MonthlyReportPdfTextFormatter();

  test('PDF money uses grouped exact integer minor-unit formatting', () {
    expect(formatter.money(const Money(minorUnits: 2420000)), 'NPR 24,200');
    expect(formatter.money(const Money(minorUnits: 9597200)), 'NPR 95,972');
    expect(formatter.money(const Money(minorUnits: 1000)), 'NPR 10');
    expect(formatter.money(const Money(minorUnits: -7177200)), '-NPR 71,772');
    expect(formatter.money(const Money(minorUnits: 123456)), 'NPR 1,234.56');
  });

  test('PDF timestamp and logical header are human-readable', () {
    final String timestamp = formatter.generatedAt(
      DateTime(2026, 8, 12, 22, 7, 32, 105),
    );

    expect(timestamp, 'Generated 12 August 2026, 10:07 PM');
    expect(timestamp, isNot(contains('T22:07')));
    expect(timestamp, isNot(contains('.105')));
    expect(timestamp, isNot(endsWith('Z')));
    expect(formatter.header(isMonthToDate: true), 'MONTH TO DATE');
    expect(formatter.header(isMonthToDate: false), 'MONTHLY REPORT');
  });

  test('insufficient comparison omits misleading metric rows', () {
    final period = calendar.periodFor(
      calendarSystem: AppCalendarSystem.gregorianAd,
      year: 2026,
      month: 8,
    );
    final comparison = reportService.compare(
      selectedPeriod: period,
      activities: <FinancialActivity>[
        TransactionActivity(buildTestTransaction(id: 'current')),
      ],
      now: DateTime.utc(2026, 8, 10),
    );
    final content = formatter.comparison(comparison);

    expect(content.periods, 'August 2026 vs July 2026');
    expect(
      content.scope,
      'Compared with the same elapsed portion of the previous month.',
    );
    expect(content.metrics, isEmpty);
    expect(content.explanation, contains('Not enough recorded activity'));
    expect(content.explanation, isNot(contains('Not comparable')));
  });

  test('valid comparison retains grouped income expense and net rows', () {
    final period = calendar.periodFor(
      calendarSystem: AppCalendarSystem.gregorianAd,
      year: 2026,
      month: 8,
    );
    final comparison = reportService.compare(
      selectedPeriod: period,
      activities: <FinancialActivity>[
        TransactionActivity(
          buildTestTransaction(
            id: 'previous-income',
            type: TransactionType.income,
            category: TransactionCategory.salary,
            minorUnits: 1200000,
            occurredAt: DateTime.utc(2026, 7, 4),
          ),
        ),
        TransactionActivity(
          buildTestTransaction(
            id: 'previous-expense',
            minorUnits: 300000,
            occurredAt: DateTime.utc(2026, 7, 4),
          ),
        ),
        TransactionActivity(
          buildTestTransaction(
            id: 'current-income',
            type: TransactionType.income,
            category: TransactionCategory.salary,
            minorUnits: 2420000,
          ),
        ),
        TransactionActivity(
          buildTestTransaction(id: 'current-expense', minorUnits: 9597200),
        ),
      ],
      now: DateTime.utc(2026, 8, 10),
    );
    final content = formatter.comparison(comparison);

    expect(content.metrics.map((value) => value.label), <String>[
      'Income',
      'Expenses',
      'Net change',
    ]);
    expect(content.metrics[0].value, contains('NPR 12,000'));
    expect(content.metrics[0].value, contains('NPR 24,200'));
    expect(content.metrics[1].value, contains('NPR 95,972'));
    expect(content.metrics[2].value, contains('-NPR 71,772'));
  });
}
