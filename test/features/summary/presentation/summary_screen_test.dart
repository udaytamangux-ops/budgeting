import 'package:budgeting_app/features/summary/domain/entities/monthly_transaction_summary.dart';
import 'package:budgeting_app/features/summary/presentation/widgets/spending_donut_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

void main() {
  testWidgets('Summary presents neutral monthly financial records', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester);
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();

    expect(find.text('August 2026'), findsOneWidget);
    expect(find.text('This month'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Net change'), findsOneWidget);
    expect(find.text('+NPR 37,250'), findsOneWidget);
    expect(find.text('6 recorded'), findsOneWidget);
    expect(find.text('Where your money went'), findsOneWidget);
    expect(find.byType(SpendingDonutChart), findsOneWidget);
    expect(find.text('Payment methods'), findsNothing);

    final SpendingDonutChart chart = tester.widget<SpendingDonutChart>(
      find.byType(SpendingDonutChart),
    );
    expect(chart.total.minorUnits, 2275000);
    expect(
      chart.groups.fold<int>(
        0,
        (int total, CategorySpendingGroup group) =>
            total + group.amount.minorUnits,
      ),
      chart.total.minorUnits,
    );
    expect(
      chart.groups.fold<int>(
        0,
        (int total, CategorySpendingGroup group) =>
            total + group.sharePercentage,
      ),
      100,
    );
    expect(
      find.bySemanticsLabel(RegExp('Total recorded expenses, NPR 22,750')),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('Category breakdown'),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Category breakdown'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Food'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('NPR 5,500'), findsOneWidget);
    expect(find.text('24% of recorded expenses'), findsOneWidget);
    expect(find.text('Payment methods'), findsNothing);
  });

  testWidgets('month selector updates every month-scoped summary section', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester);
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();

    final IconButton currentMonthNext = tester.widget<IconButton>(
      find.byKey(const ValueKey<String>('next_month_button')),
    );
    expect(currentMonthNext.onPressed, isNull);
    expect(
      find.bySemanticsLabel('Selected month, August 2026'),
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
        (int total, CategorySpendingGroup group) =>
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

  testWidgets('Summary contains no budgeting guidance language', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester);
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
