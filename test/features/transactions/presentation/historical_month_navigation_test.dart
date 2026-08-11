import 'package:budgeting_app/features/summary/presentation/widgets/spending_donut_chart.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/quick_date_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';
import '../../../support/test_data.dart';

void main() {
  testWidgets('Home Transactions and Summary share the selected real month', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester, useMockTransactions: true);

    await tester.tap(
      find.byKey(const ValueKey<String>('previous_month_button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('July 2026'), findsWidgets);
    expect(find.text('NPR 38,400'), findsOneWidget);
    expect(find.text('NPR 21,600'), findsOneWidget);
    expect(find.text('Current month'), findsOneWidget);

    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    expect(find.text('July 2026'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Bhat-Bhateni Maharajgunj'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Bhat-Bhateni Maharajgunj'), findsOneWidget);
    expect(find.text('Kathmandu Lunch Club'), findsNothing);

    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    expect(find.text('July 2026'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byType(SpendingDonutChart),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      tester.widget<SpendingDonutChart>(find.byType(SpendingDonutChart)).total,
      const Money(minorUnits: 2160000),
    );

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('return_current_month')),
      -220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('return_current_month')),
    );
    await tester.pumpAndSettle();
    await tester.fling(
      find.byType(ListView).first,
      const Offset(0, 1000),
      1000,
    );
    await tester.pumpAndSettle();
    expect(find.text('August 2026'), findsOneWidget);
    expect(find.text('Current month'), findsNothing);
  });

  testWidgets('month picker selects history and disables future months', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester, useMockTransactions: true);
    await tester.tap(find.byKey(const ValueKey<String>('select_month_button')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('calendar_period_picker')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<OutlinedButton>(
            find.byKey(const ValueKey<String>('month_option_2026_9')),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const ValueKey<String>('month_option_2026_7')));
    await tester.pumpAndSettle();
    expect(find.text('July 2026'), findsWidgets);
  });

  testWidgets('browsing history never changes a new transaction date', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester, useMockTransactions: true);
    await tester.tap(
      find.byKey(const ValueKey<String>('previous_month_button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('July 2026'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey<String>('central_add_button')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('quick_date_today')),
      260,
      scrollable: _formScrollable(),
    );
    final QuickDateSelector selector = tester.widget<QuickDateSelector>(
      find.byType(QuickDateSelector),
    );
    expect(selector.date.year, fixedNow.toLocal().year);
    expect(selector.date.month, fixedNow.toLocal().month);
    expect(selector.date.day, fixedNow.toLocal().day);
  });

  testWidgets('minimizing Add preserves the underlying historical month', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester, useMockTransactions: true);
    await tester.tap(
      find.byKey(const ValueKey<String>('previous_month_button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('July 2026'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey<String>('central_add_button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey<String>('amount_input')),
      '250',
    );
    await tester.fling(
      find.byKey(const ValueKey<String>('sheet_dismiss_intent_region')),
      const Offset(0, 140),
      1300,
    );
    await tester.pumpAndSettle();

    expect(find.text('July 2026'), findsWidgets);
    expect(
      find.byKey(const ValueKey<String>('new_transaction_sheet')),
      findsNothing,
    );
  });

  testWidgets('legacy future records extend browsing but not Add defaults', (
    WidgetTester tester,
  ) async {
    final FinancialTransaction legacyFuture = buildTestTransaction(
      id: 'legacy-future-visible',
      merchant: 'Legacy future record',
      occurredAt: DateTime.utc(2026, 11, 2, 12),
    );
    await pumpBudgetingApp(
      tester,
      seedTransactions: <FinancialTransaction>[legacyFuture],
    );

    for (int index = 0; index < 3; index += 1) {
      await tester.tap(find.byKey(const ValueKey<String>('next_month_button')));
      await tester.pumpAndSettle();
    }
    expect(find.text('November 2026'), findsWidgets);
    expect(
      tester
          .widget<IconButton>(
            find.byKey(const ValueKey<String>('next_month_button')),
          )
          .onPressed,
      isNull,
    );
    await tester.scrollUntilVisible(
      find.text('Legacy future record'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Legacy future record'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('central_add_button')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('quick_date_today')),
      260,
      scrollable: _formScrollable(),
    );
    final QuickDateSelector selector = tester.widget<QuickDateSelector>(
      find.byType(QuickDateSelector),
    );
    expect(selector.date.day, fixedNow.toLocal().day);
    expect(selector.date.month, fixedNow.toLocal().month);
    expect(selector.date.year, fixedNow.toLocal().year);
  });
}

Finder _formScrollable() {
  return find
      .descendant(
        of: find.byKey(const ValueKey<String>('add_transaction_form_scroll')),
        matching: find.byType(Scrollable),
      )
      .first;
}
