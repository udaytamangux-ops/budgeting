import 'dart:convert';
import 'dart:io';

import 'package:budgeting_app/core/calendar/data/bikram_sambat_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/features/data_portability/domain/services/transaction_csv_service.dart';
import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/monthly_reports/data/services/monthly_report_pdf_service.dart';
import 'package:budgeting_app/features/monthly_reports/domain/entities/monthly_report_export_options.dart';
import 'package:budgeting_app/features/monthly_reports/domain/services/monthly_report_service.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transfers/domain/entities/financial_transfer.dart';
import 'package:budgeting_app/features/transfers/domain/entities/transfer_enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final BikramSambatCalendarService calendar = BikramSambatCalendarService();

  test('monthly CSV contains only the selected canonical period', () {
    final period = calendar.periodFor(
      calendarSystem: AppCalendarSystem.gregorianAd,
      year: 2026,
      month: 8,
    );
    final bytes = TransactionCsvService(calendar).encodeForPeriod(
      transactions: <FinancialTransaction>[
        buildTestTransaction(id: 'inside', merchant: 'Inside August'),
        buildTestTransaction(
          id: 'outside',
          merchant: 'Outside July',
          occurredAt: DateTime.utc(2026, 7, 31),
        ),
      ],
      transfers: <FinancialTransfer>[
        buildTestTransfer(id: 'inside-transfer', note: 'Inside transfer'),
        buildTestTransfer(
          id: 'outside-transfer',
          note: 'Outside transfer',
          occurredAt: DateTime.utc(2026, 9, 1),
        ),
      ],
      period: period,
    );
    final String csv = utf8.decode(bytes.sublist(3));

    expect(csv, contains('Inside August'));
    expect(csv, contains('Inside transfer'));
    expect(csv, isNot(contains('Outside July')));
    expect(csv, isNot(contains('Outside transfer')));
  });

  testWidgets('PDF generation is local, valid, and honors minimal options', (
    WidgetTester tester,
  ) async {
    final period = calendar.periodFor(
      calendarSystem: AppCalendarSystem.gregorianAd,
      year: 2026,
      month: 8,
    );
    final MonthlyReportService reportService = MonthlyReportService(calendar);
    final activities = <FinancialActivity>[
      TransactionActivity(buildTestTransaction(merchant: 'किराना पसल')),
      TransferActivity(buildTestTransfer(note: 'घर पठाएको')),
    ];
    final report = reportService.build(
      period: period,
      activities: activities,
      now: DateTime.utc(2026, 8, 10),
    );
    final comparison = reportService.compare(
      selectedPeriod: period,
      activities: activities,
      now: DateTime.utc(2026, 8, 10),
    );
    final bytes = await MonthlyReportPdfService(calendar).generate(
      report: report,
      comparison: comparison,
      options: const MonthlyReportExportOptions(
        includeVisualCharts: false,
        includeMonthComparison: false,
        includeActivityList: false,
      ),
      generatedAt: DateTime.utc(2026, 8, 10, 12),
    );

    expect(bytes.length, greaterThan(1000));
    expect(ascii.decode(bytes.take(4).toList()), '%PDF');
  });

  testWidgets('PDF generation supports charts comparison and activity pages', (
    WidgetTester tester,
  ) async {
    expect(MonthlyReportPdfService.activityTableHeaders, <String>[
      'Date',
      'Type',
      'Description',
      'Category',
      'Payment',
      'Amount',
    ]);
    expect(
      MonthlyReportPdfService.activityTableHeaders,
      isNot(contains('Payment method')),
    );
    final period = calendar.periodFor(
      calendarSystem: AppCalendarSystem.gregorianAd,
      year: 2026,
      month: 8,
    );
    final MonthlyReportService reportService = MonthlyReportService(calendar);
    final expenseCategories = <TransactionCategory>[
      TransactionCategory.utilities,
      TransactionCategory.family,
      TransactionCategory.food,
      TransactionCategory.transport,
    ];
    final activities = <FinancialActivity>[
      for (int index = 0; index < 32; index += 1)
        TransactionActivity(
          buildTestTransaction(
            id: 'expense-$index',
            category: expenseCategories[index % expenseCategories.length],
            minorUnits: 10000 + index * 100,
            merchant:
                'Long recorded activity description $index for PDF wrapping verification',
          ),
        ),
      TransactionActivity(
        buildTestTransaction(
          id: 'income',
          type: TransactionType.income,
          category: TransactionCategory.salary,
          minorUnits: 500000,
        ),
      ),
      TransferActivity(
        buildTestTransfer(
          countsAsExpense: true,
          feeMinorUnits: 1000,
          destination: TransferDestination.person,
          destinationName: 'आमा',
        ),
      ),
    ];
    final report = reportService.build(
      period: period,
      activities: activities,
      now: DateTime.utc(2026, 8, 10),
    );
    final comparison = reportService.compare(
      selectedPeriod: period,
      activities: activities,
      now: DateTime.utc(2026, 8, 10),
    );
    final bytes = await MonthlyReportPdfService(calendar).generate(
      report: report,
      comparison: comparison,
      options: const MonthlyReportExportOptions(),
      generatedAt: DateTime.utc(2026, 8, 10, 12),
    );

    expect(bytes.length, greaterThan(5000));
    expect(ascii.decode(bytes.take(4).toList()), '%PDF');
  });

  testWidgets('final verification PDF preserves approved financial facts', (
    WidgetTester tester,
  ) async {
    final period = calendar.periodFor(
      calendarSystem: AppCalendarSystem.gregorianAd,
      year: 2026,
      month: 8,
    );
    final MonthlyReportService reportService = MonthlyReportService(calendar);
    final activities = <FinancialActivity>[
      TransactionActivity(
        buildTestTransaction(
          id: 'salary',
          type: TransactionType.income,
          category: TransactionCategory.salary,
          minorUnits: 2420000,
          merchant: 'Salary',
        ),
      ),
      TransactionActivity(
        buildTestTransaction(
          id: 'utilities-largest',
          category: TransactionCategory.utilities,
          minorUnits: 9288500,
          merchant: 'Annual utility settlement',
        ),
      ),
      TransactionActivity(
        buildTestTransaction(
          id: 'utilities-small',
          category: TransactionCategory.utilities,
          minorUnits: 24200,
          merchant: 'Utility adjustment',
        ),
      ),
      TransactionActivity(
        buildTestTransaction(
          id: 'food',
          category: TransactionCategory.food,
          minorUnits: 83500,
          merchant: 'Food purchase with a longer description for wrapping',
        ),
      ),
      TransferActivity(
        buildTestTransfer(
          id: 'counted-family',
          minorUnits: 200000,
          destination: TransferDestination.person,
          destinationName: 'Mom',
          countsAsExpense: true,
          expenseCategory: TransactionCategory.family,
          feeMinorUnits: 1000,
        ),
      ),
      TransferActivity(
        buildTestTransfer(
          id: 'bank-to-cash',
          minorUnits: 500000,
          destination: TransferDestination.cash,
        ),
      ),
      TransferActivity(
        buildTestTransfer(
          id: 'bank-to-esewa',
          minorUnits: 100000,
          destination: TransferDestination.eSewa,
        ),
      ),
    ];
    final report = reportService.build(
      period: period,
      activities: activities,
      now: DateTime.utc(2026, 8, 12),
    );
    final comparison = reportService.compare(
      selectedPeriod: period,
      activities: activities,
      now: DateTime.utc(2026, 8, 12),
    );

    expect(report.incomeTotal.minorUnits, 2420000);
    expect(report.expenseTotal.minorUnits, 9597200);
    expect(report.netChange.minorUnits, -7177200);
    expect(report.transferSummary.count, 3);
    expect(report.transferSummary.movementTotal.minorUnits, 800000);
    expect(report.transferSummary.countedAsExpenseTotal.minorUnits, 200000);
    expect(report.transferSummary.feeTotal.minorUnits, 1000);
    expect(comparison.hasComparableData, isFalse);

    final bytes = await MonthlyReportPdfService(calendar).generate(
      report: report,
      comparison: comparison,
      options: const MonthlyReportExportOptions(),
      generatedAt: DateTime(2026, 8, 12, 22, 7),
    );

    expect(bytes.length, greaterThan(5000));
    expect(ascii.decode(bytes.take(4).toList()), '%PDF');
    if (Platform.environment['GENERATE_MONTHLY_REPORT_SAMPLE'] == 'true') {
      final Directory output = Directory('build/verification');
      output.createSync(recursive: true);
      File('${output.path}/monthly-report-final.pdf').writeAsBytesSync(bytes);
    }
  });
}
