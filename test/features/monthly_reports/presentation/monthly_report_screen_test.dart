import 'package:budgeting_app/features/monthly_reports/domain/entities/monthly_report_data.dart';
import 'package:budgeting_app/features/monthly_reports/presentation/widgets/report_donut_chart.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transfers/domain/entities/financial_transfer.dart';
import 'package:budgeting_app/features/transfers/domain/entities/transfer_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';
import '../../../support/test_data.dart';

void main() {
  testWidgets('Summary opens the report for its shared selected month', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(
      tester,
      seedTransactions: <FinancialTransaction>[
        buildTestTransaction(
          id: 'income',
          type: TransactionType.income,
          category: TransactionCategory.salary,
          minorUnits: 1000000,
        ),
        buildTestTransaction(id: 'expense', minorUnits: 250000),
      ],
      seedTransfers: <FinancialTransfer>[
        buildTestTransfer(
          countsAsExpense: true,
          expenseCategory: TransactionCategory.family,
          minorUnits: 100000,
          feeMinorUnits: 1000,
        ),
      ],
    );
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('open_monthly_report')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey<String>('open_monthly_report')));
    await tester.pumpAndSettle();

    expect(find.text('Monthly Report'), findsOneWidget);
    expect(find.text('Month to date'), findsOneWidget);
    expect(find.text('August 2026'), findsWidgets);
    expect(find.text('NPR 10,000'), findsOneWidget);
    expect(find.text('NPR 3,510'), findsOneWidget);
    expect(find.text('3 recorded'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Transfer activity'),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('NPR 1,000 counted as expense'), findsOneWidget);
    expect(find.text('NPR 10 fees'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Compare with same point last month'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Compare with same point last month'), findsOneWidget);
  });

  testWidgets('human-friendly percentages remain beside exact legend amounts', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ReportDonutChart(
            title: 'Expenses',
            emptyMessage: 'No expenses',
            slices: <ReportChartSlice>[
              ReportChartSlice(
                label: 'Utilities',
                amount: Money(minorUnits: 9312700),
                basisPoints: 9704,
                categories: <TransactionCategory>[
                  TransactionCategory.utilities,
                ],
              ),
              ReportChartSlice(
                label: 'Family',
                amount: Money(minorUnits: 200000),
                basisPoints: 208,
                categories: <TransactionCategory>[TransactionCategory.family],
              ),
              ReportChartSlice(
                label: 'Food',
                amount: Money(minorUnits: 83500),
                basisPoints: 87,
                categories: <TransactionCategory>[TransactionCategory.food],
              ),
              ReportChartSlice(
                label: 'Fees & Charges',
                amount: Money(minorUnits: 1000),
                basisPoints: 1,
                categories: <TransactionCategory>[
                  TransactionCategory.feesAndCharges,
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('NPR 93,127 · 97%'), findsOneWidget);
    expect(find.text('NPR 2,000 · 2%'), findsOneWidget);
    expect(find.text('NPR 835 · 0.9%'), findsOneWidget);
    expect(find.text('NPR 10 · <0.1%'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        RegExp('Utilities, NPR 93,127, 97%.*Fees & Charges, NPR 10, <0.1%'),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'visual report provides charts and accessible text alternatives',
    (WidgetTester tester) async {
      await pumpBudgetingApp(tester, useMockTransactions: true);
      await tester.tap(find.text('Summary'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('open_monthly_report')),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('open_monthly_report')),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('View visual breakdown'),
        280,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('View visual breakdown'));
      await tester.pumpAndSettle();

      expect(find.text('Visual report'), findsOneWidget);
      expect(find.byType(ReportDonutChart), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('Expenses breakdown.*Food.*NPR')),
        findsOneWidget,
      );
      expect(find.text('Expense category values'), findsNothing);
      expect(find.text('Highest expense category'), findsOneWidget);
      expect(find.text('Largest expense activity'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('income_single_category')),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.byKey(const ValueKey<String>('income_single_category')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('income_donut_chart')),
        findsNothing,
      );
      expect(find.text('Income source values'), findsNothing);
    },
  );

  testWidgets('zero and one category avoid meaningless donut charts', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(
      tester,
      seedTransactions: <FinancialTransaction>[
        buildTestTransaction(
          id: 'salary-only',
          type: TransactionType.income,
          category: TransactionCategory.salary,
          minorUnits: 2420000,
        ),
      ],
    );
    await _openVisualReport(tester);

    expect(
      find.byKey(const ValueKey<String>('expenses_empty_breakdown')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('expenses_donut_chart')),
      findsNothing,
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('income_single_category')),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.byKey(const ValueKey<String>('income_single_category')),
      findsOneWidget,
    );
    expect(find.text('NPR 24,200'), findsOneWidget);
    expect(find.text('100% of recorded income'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('income_donut_chart')),
      findsNothing,
    );
  });

  testWidgets('one expense category is summarized without a donut', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(
      tester,
      seedTransactions: <FinancialTransaction>[
        buildTestTransaction(id: 'food-only', minorUnits: 83500),
      ],
    );
    await _openVisualReport(tester);
    expect(
      find.byKey(const ValueKey<String>('expenses_single_category')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('expenses_donut_chart')),
      findsNothing,
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('income_empty_breakdown')),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.byKey(const ValueKey<String>('income_empty_breakdown')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('income_donut_chart')),
      findsNothing,
    );
  });

  testWidgets('two expense categories use a donut', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(
      tester,
      seedTransactions: <FinancialTransaction>[
        buildTestTransaction(id: 'food', minorUnits: 83500),
        buildTestTransaction(
          id: 'utilities',
          category: TransactionCategory.utilities,
          minorUnits: 9312700,
        ),
      ],
    );
    await _openVisualReport(tester);
    expect(
      find.byKey(const ValueKey<String>('expenses_donut_chart')),
      findsOneWidget,
    );
  });

  testWidgets('counted transfer highlight remains a Transfer without its fee', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(
      tester,
      seedTransfers: <FinancialTransfer>[
        buildTestTransfer(
          minorUnits: 200000,
          countsAsExpense: true,
          expenseCategory: TransactionCategory.family,
          feeMinorUnits: 1000,
          destinationName: 'Mom',
          destination: TransferDestination.person,
        ),
      ],
    );
    await _openVisualReport(tester);

    expect(find.text('Largest expense activity'), findsOneWidget);
    expect(
      find.textContaining('Transfer · Counted as expense'),
      findsOneWidget,
    );
    expect(find.text('NPR 2,000'), findsWidgets);
    expect(find.text('NPR 2,010'), findsNothing);
  });

  testWidgets('report remains overflow-free at 320px and 2x text', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpBudgetingApp(tester, useMockTransactions: true);
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('open_monthly_report')),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -180));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('open_monthly_report')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Monthly Report'), findsOneWidget);
  });
}

Future<void> _openVisualReport(WidgetTester tester) async {
  await tester.tap(find.text('Summary'));
  await tester.pumpAndSettle();
  final Finder summaryScrollable = find.descendant(
    of: find.byKey(const ValueKey<String>('summary_content')),
    matching: find.byType(Scrollable),
  );
  await tester.scrollUntilVisible(
    find.byKey(const ValueKey<String>('open_monthly_report')),
    240,
    scrollable: summaryScrollable.first,
  );
  await tester.drag(
    find.byKey(const ValueKey<String>('summary_content')),
    const Offset(0, -100),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey<String>('open_monthly_report')));
  await tester.pumpAndSettle();
  final Finder reportScrollable = find.descendant(
    of: find.byKey(const ValueKey<String>('monthly_report_content')),
    matching: find.byType(Scrollable),
  );
  await tester.scrollUntilVisible(
    find.text('View visual breakdown'),
    280,
    scrollable: reportScrollable.first,
  );
  await tester.drag(
    find.byKey(const ValueKey<String>('monthly_report_content')),
    const Offset(0, -80),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('View visual breakdown'));
  await tester.pumpAndSettle();
}
