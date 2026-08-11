import 'dart:ui' show SemanticsAction, Tristate;

import 'package:budgeting_app/core/formatting/currency_formatter.dart';
import 'package:budgeting_app/features/summary/domain/entities/monthly_category_activity.dart';
import 'package:budgeting_app/features/summary/presentation/screens/summary_screen.dart';
import 'package:budgeting_app/features/summary/presentation/widgets/spending_donut_chart.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';
import '../../../support/test_data.dart';

void main() {
  testWidgets('Summary presents neutral monthly financial records', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester, useMockTransactions: true);
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();

    expect(find.text('August 2026'), findsOneWidget);
    expect(find.text('Period activity'), findsOneWidget);
    expect(find.text('Income'), findsWidgets);
    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Net change'), findsOneWidget);
    expect(find.text('+NPR 37,250'), findsOneWidget);
    expect(find.text('6 recorded'), findsOneWidget);
    expect(find.text('Where your money went'), findsOneWidget);
    expect(find.byType(SpendingDonutChart), findsOneWidget);
    expect(find.text('Payment methods'), findsNothing);
    expect(find.text('All categories'), findsNothing);
    expect(find.text('View transactions'), findsNothing);
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey<String>('donut_center_label')),
          )
          .data,
      'Recorded expenses',
    );
    expect(
      find.byKey(const ValueKey<String>('donut_center_percentage')),
      findsNothing,
    );

    final SpendingDonutChart chart = tester.widget<SpendingDonutChart>(
      find.byType(SpendingDonutChart),
    );
    expect(chart.total.minorUnits, 2275000);
    expect(
      chart.groups.fold<int>(
        0,
        (int total, CategoryActivityGroup group) =>
            total + group.amount.minorUnits,
      ),
      chart.total.minorUnits,
    );
    expect(
      chart.groups.fold<int>(
        0,
        (int total, CategoryActivityGroup group) =>
            total + group.sharePercentage,
      ),
      100,
    );
    expect(
      find.bySemanticsLabel(RegExp('Total recorded expenses, NPR 22,750')),
      findsOneWidget,
    );

    await _revealSummary(tester, find.text('Category breakdown'));
    expect(find.text('Category breakdown'), findsOneWidget);
    await _revealSummary(tester, find.text('Food'));
    expect(find.text('NPR 5,500'), findsOneWidget);
    expect(find.text('24% of recorded expenses'), findsOneWidget);
    expect(find.text('Payment methods'), findsNothing);
  });

  testWidgets('breakdown rows and chart share one explicit selection state', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester, useMockTransactions: true);
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();

    final Finder foodRow = find.byKey(
      const ValueKey<String>('summary_category_row_food'),
    );
    await _revealSummary(tester, foodRow);
    await tester.tap(foodRow);
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(foodRow).flagsCollection.isSelected,
      Tristate.isTrue,
    );
    expect(
      tester
          .getSemantics(
            find.byKey(const ValueKey<String>('donut_segment_food')),
          )
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
    );
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey<String>('donut_center_label')),
          )
          .data,
      'Food',
    );
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey<String>('donut_center_amount')),
          )
          .data,
      'NPR 5,500',
    );
    expect(find.text('24%'), findsOneWidget);
    expect(find.text('View transactions'), findsOneWidget);
    expect(find.text('All categories'), findsOneWidget);

    final Finder utilitiesRow = find.byKey(
      const ValueKey<String>('summary_category_row_utilities'),
    );
    await _revealSummary(tester, utilitiesRow);
    await tester.tap(utilitiesRow);
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(foodRow).flagsCollection.isSelected,
      Tristate.isFalse,
    );
    expect(
      tester.getSemantics(utilitiesRow).flagsCollection.isSelected,
      Tristate.isTrue,
    );
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey<String>('donut_center_label')),
          )
          .data,
      'Utilities',
    );

    await _revealSummary(
      tester,
      find.byKey(const ValueKey<String>('all_categories_button')),
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('all_categories_button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('View transactions'), findsNothing);
    expect(find.text('All categories'), findsNothing);
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey<String>('donut_center_label')),
          )
          .data,
      'Recorded expenses',
    );
  });

  testWidgets('a donut segment selects its matching breakdown row', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester, useMockTransactions: true);
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    final Finder segment = find.byKey(
      const ValueKey<String>('donut_segment_transport'),
    );
    await _revealSummary(tester, segment);

    await tester.tapAt(tester.getCenter(segment));
    await tester.pumpAndSettle();

    final Finder row = find.byKey(
      const ValueKey<String>('summary_category_row_transport'),
    );
    await _revealSummary(tester, row);
    expect(
      tester.getSemantics(segment).flagsCollection.isSelected,
      Tristate.isTrue,
    );
    expect(
      tester.getSemantics(row).flagsCollection.isSelected,
      Tristate.isTrue,
    );
    expect(find.bySemanticsLabel(RegExp('Transport.*9 percent')), findsWidgets);
  });

  testWidgets('income-source exploration uses recorded monthly income', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester, useMockTransactions: true);
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    final Finder incomeSelector = find.byKey(
      const ValueKey<String>('transaction_type_income'),
    );
    await _revealSummary(tester, incomeSelector);

    await tester.tap(incomeSelector);
    await tester.pumpAndSettle();

    expect(find.text('Where income came from'), findsOneWidget);
    expect(find.text('Income source breakdown'), findsOneWidget);
    final SpendingDonutChart chart = tester.widget<SpendingDonutChart>(
      find.byType(SpendingDonutChart),
    );
    expect(chart.type, TransactionType.income);
    expect(chart.total.minorUnits, 6000000);
    expect(chart.groups, hasLength(1));
    expect(chart.groups.single.category, TransactionCategory.salary);
    expect(find.bySemanticsLabel(RegExp('Salary.*100 percent')), findsWidgets);
  });

  testWidgets('zero-total donut has finite geometry and neutral content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SpendingDonutChart(
            groups: const <CategoryActivityGroup>[],
            total: const Money.zero(),
            type: TransactionType.expense,
            currencyFormatter: CurrencyFormatter(),
            onGroupSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('NPR 0'), findsOneWidget);
    expect(find.textContaining('NaN'), findsNothing);
    expect(find.textContaining('Infinity'), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('donut_segment_food')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a one-percent donut segment remains labelled and tappable', (
    WidgetTester tester,
  ) async {
    CategoryActivityGroup? selectedGroup;
    final List<CategoryActivityGroup> groups = <CategoryActivityGroup>[
      const CategoryActivityGroup(
        category: TransactionCategory.food,
        includedCategories: <TransactionCategory>[TransactionCategory.food],
        amount: Money(minorUnits: 9900),
        sharePercentage: 99,
        transactionCount: 1,
      ),
      const CategoryActivityGroup(
        category: TransactionCategory.transport,
        includedCategories: <TransactionCategory>[
          TransactionCategory.transport,
        ],
        amount: Money(minorUnits: 100),
        sharePercentage: 1,
        transactionCount: 1,
      ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SpendingDonutChart(
              groups: groups,
              total: const Money(minorUnits: 10000),
              type: TransactionType.expense,
              currencyFormatter: CurrencyFormatter(),
              onGroupSelected: (CategoryActivityGroup value) {
                selectedGroup = value;
              },
            ),
          ),
        ),
      ),
    );

    final Finder smallSegment = find.byKey(
      const ValueKey<String>('donut_segment_transport'),
    );
    expect(tester.getSize(smallSegment), const Size.square(48));
    final SemanticsNode semantics = tester.getSemantics(smallSegment);
    expect(semantics.label, contains('Transport, NPR 1, 1 percent'));
    expect(semantics.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);

    await tester.tapAt(tester.getCenter(smallSegment));
    await tester.pump();

    expect(selectedGroup?.category, TransactionCategory.transport);
    expect(tester.takeException(), isNull);
  });

  testWidgets('category rows expose non-colour selected semantics', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semanticsHandle = tester.ensureSemantics();
    await pumpBudgetingApp(tester, useMockTransactions: true);
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    final Finder foodRow = find.byKey(
      const ValueKey<String>('summary_category_row_food'),
    );
    await _revealSummary(tester, foodRow);

    final SemanticsNode unselected = tester.getSemantics(foodRow);
    expect(unselected.label, contains('Food, NPR 5,500'));
    expect(
      unselected.getSemanticsData().hasAction(SemanticsAction.tap),
      isTrue,
    );
    expect(unselected.flagsCollection.isSelected, Tristate.isFalse);

    await tester.tap(foodRow);
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(foodRow).flagsCollection.isSelected,
      Tristate.isTrue,
    );
    expect(
      find.descendant(
        of: foodRow,
        matching: find.byKey(
          const ValueKey<String>('selected_record_indicator'),
        ),
      ),
      findsOneWidget,
    );
    expect(tester.getSize(foodRow).height, greaterThanOrEqualTo(48));
    semanticsHandle.dispose();
  });

  testWidgets('category exploration fits 320 px with 2x text scaling', (
    WidgetTester tester,
  ) async {
    _configureView(tester, width: 320, textScale: 2);
    await pumpBudgetingApp(tester, useMockTransactions: true);
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    final Finder foodRow = find.byKey(
      const ValueKey<String>('summary_category_row_food'),
    );
    await _revealSummary(tester, foodRow);
    await tester.tap(foodRow);
    await tester.pumpAndSettle();
    await _revealSummary(
      tester,
      find.byKey(const ValueKey<String>('view_category_transactions_button')),
    );

    expect(find.text('View transactions'), findsOneWidget);
    expect(find.text('All categories'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('category exploration remains bounded at 768 px', (
    WidgetTester tester,
  ) async {
    _configureView(tester, width: 768);
    await pumpBudgetingApp(tester, useMockTransactions: true);
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    await _revealSummary(
      tester,
      find.byKey(const ValueKey<String>('summary_category_row_food')),
    );

    expect(find.text('Category breakdown'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('category selection resolves immediately with reduced motion', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpBudgetingApp(tester, useMockTransactions: true);
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    final Finder foodRow = find.byKey(
      const ValueKey<String>('summary_category_row_food'),
    );
    await _revealSummary(tester, foodRow);

    await tester.tap(foodRow);
    await tester.pump();

    final AnimatedContainer selectedSurface = tester.widget<AnimatedContainer>(
      find.descendant(of: foodRow, matching: find.byType(AnimatedContainer)),
    );
    expect(selectedSurface.duration, Duration.zero);
    expect(tester.takeException(), isNull);
  });

  testWidgets('month selector updates every month-scoped summary section', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester, useMockTransactions: true);
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();

    final IconButton currentMonthNext = tester.widget<IconButton>(
      find.byKey(const ValueKey<String>('next_month_button')),
    );
    expect(currentMonthNext.onPressed, isNull);
    expect(
      find.bySemanticsLabel(RegExp('Select month, August 2026')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('previous_month_button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('July 2026'), findsOneWidget);
    expect(find.text('NPR 21,600'), findsWidgets);
    expect(find.text('+NPR 38,400'), findsOneWidget);
    expect(find.text('5 recorded'), findsOneWidget);
    final SpendingDonutChart previousMonthChart = tester
        .widget<SpendingDonutChart>(find.byType(SpendingDonutChart));
    expect(previousMonthChart.total.minorUnits, 2160000);
    expect(
      previousMonthChart.groups.fold<int>(
        0,
        (int total, CategoryActivityGroup group) =>
            total + group.sharePercentage,
      ),
      100,
    );
    expect(
      tester
          .widget<IconButton>(
            find.byKey(const ValueKey<String>('next_month_button')),
          )
          .onPressed,
      isNotNull,
    );

    await tester.tap(find.byKey(const ValueKey<String>('next_month_button')));
    await tester.pumpAndSettle();
    expect(find.text('August 2026'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.byKey(const ValueKey<String>('next_month_button')),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('empty months retain zero totals and type-specific guidance', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(
      tester,
      seedTransactions: <FinancialTransaction>[
        buildTestTransaction(occurredAt: DateTime.utc(2026, 6, 12, 6, 15)),
      ],
    );
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();

    expect(find.text('August 2026'), findsOneWidget);
    expect(find.text('0 recorded'), findsOneWidget);
    expect(find.text('No recorded expenses in August'), findsOneWidget);
    expect(
      find.text(
        'Expenses recorded for this month will appear here by category.',
      ),
      findsOneWidget,
    );
    expect(find.byType(SpendingDonutChart), findsNothing);
    expect(find.textContaining('NaN'), findsNothing);
    expect(find.textContaining('Infinity'), findsNothing);

    final Finder previousMonth = find.byKey(
      const ValueKey<String>('previous_month_button'),
    );
    await tester.tap(previousMonth);
    await tester.pumpAndSettle();
    expect(find.text('No recorded expenses in July'), findsOneWidget);

    final Finder incomeSelector = find.byKey(
      const ValueKey<String>('transaction_type_income'),
    );
    await _revealSummary(tester, incomeSelector);
    await tester.tap(incomeSelector);
    await tester.pumpAndSettle();
    expect(find.text('No recorded income in July'), findsOneWidget);
    expect(
      find.text('Income recorded for this month will appear here by source.'),
      findsOneWidget,
    );
    expect(find.byType(SpendingDonutChart), findsNothing);

    expect(tester.takeException(), isNull);
  });

  testWidgets('Summary contains no budgeting guidance language', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester, useMockTransactions: true);
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();

    for (final String prohibitedCopy in <String>[
      'Monthly budget',
      'Food budget',
      'Near limit',
      'Over limit',
      'Within budget',
      'Safe to spend',
      'Payment methods',
    ]) {
      expect(find.text(prohibitedCopy), findsNothing);
    }
  });
}

Future<void> _revealSummary(WidgetTester tester, Finder target) async {
  if (target.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      target,
      240,
      scrollable: _summaryScrollable,
    );
  }
  await Scrollable.ensureVisible(
    tester.element(target),
    alignment: 0.45,
    duration: Duration.zero,
  );
  await tester.pump();
}

Finder get _summaryScrollable => find
    .descendant(
      of: find.byType(SummaryScreen),
      matching: find.byType(Scrollable),
    )
    .first;

void _configureView(
  WidgetTester tester, {
  required double width,
  double textScale = 1,
}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 900);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}
